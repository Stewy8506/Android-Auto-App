import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../models/route_model.dart';
import 'location_service.dart';

class NavigationService {
  final LocationService locationService;

  NavigationService(this.locationService);

  RouteModel? _route;

  final StreamController<NavigationUpdate> _controller =
      StreamController.broadcast();

  Stream<NavigationUpdate> get stream => _controller.stream;

  StreamSubscription<Position>? _locationSub;

  void startNavigation(RouteModel route) {
    _route = route;

    _locationSub = locationService.stream.listen(_onLocationUpdate);
  }

  void stopNavigation() {
    _locationSub?.cancel();
    _route = null;
  }

  void _onLocationUpdate(Position position) {
    if (_route == null) return;

    final remainingDistance = _calculateRemainingDistance(position);
    final eta = _calculateETA(remainingDistance);

    _controller.add(
      NavigationUpdate(
        position: position,
        remainingDistance: remainingDistance,
        eta: eta,
      ),
    );
  }

  double _calculateRemainingDistance(Position pos) {
    // 🔥 Better than previous: iterate along polyline
    double total = 0;

    final points = _route!.polyline;

    for (int i = 0; i < points.length - 1; i++) {
      total += Geolocator.distanceBetween(
        points[i][0],
        points[i][1],
        points[i + 1][0],
        points[i + 1][1],
      );
    }

    return total;
  }

  Duration _calculateETA(double distance) {
    const speed = 12.0; // m/s (~43 km/h realistic city avg)
    return Duration(seconds: (distance / speed).round());
  }

  void dispose() {
    _locationSub?.cancel();
    _controller.close();
  }
}

class NavigationUpdate {
  final Position position;
  final double remainingDistance;
  final Duration eta;

  NavigationUpdate({
    required this.position,
    required this.remainingDistance,
    required this.eta,
  });
}