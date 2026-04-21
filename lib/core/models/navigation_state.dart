import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_model.dart';

enum NavigationStatus {
  idle,        // nothing happening
  preview,     // route shown but not started
  navigating,  // active navigation
  paused,      // navigation paused
  completed    // reached destination
}

class NavigationState {
  final NavigationStatus status;
  final RouteModel? route;
  final double? remainingDistance;
  final Duration? eta;
  final double progress;
  final bool isRerouting;
  
  // Real-time tracking properties
  final Position? currentPosition;
  final LatLng? snappedPosition;
  final RouteStep? currentStep;
  final int? currentSegmentIndex;

  const NavigationState({
    required this.status,
    this.route,
    this.remainingDistance,
    this.eta,
    required this.progress,
    this.isRerouting = false,
    this.currentPosition,
    this.snappedPosition,
    this.currentStep,
    this.currentSegmentIndex,
  });

  NavigationState copyWith({
    NavigationStatus? status,
    RouteModel? route,
    double? remainingDistance,
    Duration? eta,
    double? progress,
    bool? isRerouting,
    Position? currentPosition,
    LatLng? snappedPosition,
    RouteStep? currentStep,
    int? currentSegmentIndex,
  }) {
    return NavigationState(
      status: status ?? this.status,
      route: route ?? this.route,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      eta: eta ?? this.eta,
      progress: progress ?? this.progress,
      isRerouting: isRerouting ?? this.isRerouting,
      currentPosition: currentPosition ?? this.currentPosition,
      snappedPosition: snappedPosition ?? this.snappedPosition,
      currentStep: currentStep ?? this.currentStep,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
    );
  }

  factory NavigationState.initial() {
    return const NavigationState(
      status: NavigationStatus.idle,
      progress: 0.0,
      isRerouting: false,
    );
  }
}