import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/route_model.dart';
import 'location_service.dart';

class NavigationService {
  final LocationService locationService;

  NavigationService(this.locationService);

  RouteModel? _route;
  int _lastSegmentIndex = 0;
  List<double> _cumulativeDistances = [];
  double _averageActiveSpeed = 12.0; // Starts at ~43 km/h baseline

  final StreamController<NavigationUpdate> _controller =
      StreamController.broadcast();

  Stream<NavigationUpdate> get stream => _controller.stream;

  StreamSubscription<Position>? _locationSub;

  void startNavigation(RouteModel route) {
    _route = route;
    _lastSegmentIndex = 0;
    _calculateCumulativeDistances(route.polyline);
    _locationSub = locationService.stream.listen(_onLocationUpdate);
  }

  void _calculateCumulativeDistances(List<List<double>> points) {
    _cumulativeDistances = List.filled(points.length, 0.0);
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += Geolocator.distanceBetween(
        points[i][0], points[i][1],
        points[i+1][0], points[i+1][1]
      );
      _cumulativeDistances[i+1] = total;
    }
  }

  void stopNavigation() {
    _locationSub?.cancel();
    _route = null;
  }

  void _onLocationUpdate(Position position) {
    if (_route == null) return;

    // Smooth out hardware velocity via Exponential Moving Average (EMA)
    // Only update if moving meaningfully to prevent ETA hitting infinity at red lights
    if (position.speed >= 1.0) {
      _averageActiveSpeed = (_averageActiveSpeed * 0.8) + (position.speed * 0.2);
    }
    
    // Clamp the lower bound strictly so sitting in traffic assumes minimum 10km/h crawl pace ETA
    final effectiveSpeed = max(3.0, _averageActiveSpeed);

    final snapData = _getSnappedData(position, _route!.polyline);
    final remainingDistance = _calculateRemainingDistance(snapData);
    final eta = _calculateETA(remainingDistance, effectiveSpeed);
    
    RouteStep? currentStep;
    if (_route!.steps != null && _route!.steps!.isNotEmpty) {
      currentStep = _getCurrentStep(remainingDistance);
    }

    _controller.add(
      NavigationUpdate(
        position: position,
        snappedPosition: snapData.snappedPosition,
        remainingDistance: remainingDistance,
        eta: eta,
        currentStep: currentStep,
        currentSegmentIndex: snapData.segmentIndex,
        isOffRoute: snapData.distanceToRoute > 75, // Threshold for rerouting
      ),
    );
  }

  _SnapData _getSnappedData(Position pos, List<List<double>> polyline) {
    if (polyline.isEmpty) {
      return _SnapData(
        snappedPosition: LatLng(pos.latitude, pos.longitude),
        segmentIndex: 0,
        distanceToRoute: 0,
      );
    }
    
    if (polyline.length == 1) {
      return _SnapData(
        snappedPosition: LatLng(polyline[0][0], polyline[0][1]),
        segmentIndex: 0,
        distanceToRoute: 0,
      );
    }

    double minDist = double.infinity;
    LatLng snapped = LatLng(pos.latitude, pos.longitude);
    int bestSegment = _lastSegmentIndex;

    // 1. Localized Search (O(1) bounds instead of O(N))
    int startIdx = max(0, _lastSegmentIndex - 3);
    int endIdx = min(polyline.length - 1, _lastSegmentIndex + 10);

    for (int i = startIdx; i < endIdx; i++) {
      final p1 = LatLng(polyline[i][0], polyline[i][1]);
      final p2 = LatLng(polyline[i+1][0], polyline[i+1][1]);
      final p = LatLng(pos.latitude, pos.longitude);

      final closest = _closestPointOnSegment(p, p1, p2);
      final dist = Geolocator.distanceBetween(
        p.latitude, p.longitude, closest.latitude, closest.longitude,
      );

      if (dist < minDist) {
        minDist = dist;
        snapped = closest;
        bestSegment = i;
      }
    }

    // Fallback to full search if jumped unexpectedly (e.g. lost GPS signal or emulator jump)
    if (minDist > 150) {
      for (int i = 0; i < polyline.length - 1; i++) {
        if (i >= startIdx && i < endIdx) continue; 
        final p1 = LatLng(polyline[i][0], polyline[i][1]);
        final p2 = LatLng(polyline[i+1][0], polyline[i+1][1]);
        final p = LatLng(pos.latitude, pos.longitude);

        final closest = _closestPointOnSegment(p, p1, p2);
        final dist = Geolocator.distanceBetween(
          p.latitude, p.longitude, closest.latitude, closest.longitude,
        );

        if (dist < minDist) {
          minDist = dist;
          snapped = closest;
          bestSegment = i;
        }
      }
    }

    _lastSegmentIndex = bestSegment;
    return _SnapData(
      snappedPosition: snapped, 
      segmentIndex: bestSegment,
      distanceToRoute: minDist,
    );
  }
  
  LatLng _closestPointOnSegment(LatLng p, LatLng a, LatLng b) {
    // Spherical geometry distortion correction
    final latRad = p.latitude * pi / 180.0;
    final cosLat = cos(latRad);

    final dx = (b.longitude - a.longitude) * cosLat;
    final dy = b.latitude - a.latitude;
    
    if (dx == 0 && dy == 0) return a;
    
    final px = (p.longitude - a.longitude) * cosLat;
    final py = p.latitude - a.latitude;

    final t = (px * dx + py * dy) / (dx * dx + dy * dy);
    
    if (t < 0) return a;
    if (t > 1) return b;
    
    return LatLng(a.latitude + t * dy, a.longitude + (t * dx) / cosLat);
  }

  double _calculateRemainingDistance(_SnapData snapData) {
    if (_route == null || _cumulativeDistances.isEmpty) return 0;
    final points = _route!.polyline;
    if (points.length <= 1) return 0;

    final idx = snapData.segmentIndex;
    if (idx >= points.length - 1) return 0;

    final totalRouteDist = _cumulativeDistances.last;
    final distToSegmentStart = _cumulativeDistances[idx];
    
    final distIntoSegment = Geolocator.distanceBetween(
      points[idx][0], points[idx][1],
      snapData.snappedPosition.latitude, snapData.snappedPosition.longitude,
    );

    final distCovered = distToSegmentStart + distIntoSegment;
    double remaining = totalRouteDist - distCovered;
    return remaining < 0 ? 0 : remaining;
  }

  RouteStep _getCurrentStep(double currentRemainingDistance) {
    if (_route!.steps == null || _route!.steps!.isEmpty) {
      return RouteStep(instruction: "Proceed to route", distance: 0, duration: 0, polyline: []);
    }
    
    double accumulatedFromEnd = 0;
    for (int i = _route!.steps!.length - 1; i >= 0; i--) {
      final step = _route!.steps![i];
      accumulatedFromEnd += step.distance;
      if (currentRemainingDistance <= accumulatedFromEnd) {
        return step;
      }
    }
    return _route!.steps!.first;
  }

  Duration _calculateETA(double distance, double dynamicSpeed) {
    return Duration(seconds: (distance / dynamicSpeed).round());
  }

  void dispose() {
    _locationSub?.cancel();
    _controller.close();
  }
}

class _SnapData {
  final LatLng snappedPosition;
  final int segmentIndex;
  final double distanceToRoute;
  _SnapData({
    required this.snappedPosition, 
    required this.segmentIndex,
    required this.distanceToRoute,
  });
}

class NavigationUpdate {
  final Position position;
  final LatLng snappedPosition;
  final double remainingDistance;
  final Duration eta;
  final RouteStep? currentStep;
  final int currentSegmentIndex;
  final bool isOffRoute;

  NavigationUpdate({
    required this.position,
    required this.snappedPosition,
    required this.remainingDistance,
    required this.eta,
    required this.currentSegmentIndex,
    this.currentStep,
    this.isOffRoute = false,
  });
}