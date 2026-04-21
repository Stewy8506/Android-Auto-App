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

  const NavigationState({
    required this.status,
    this.route,
    this.remainingDistance,
    this.eta,
  });

  NavigationState copyWith({
    NavigationStatus? status,
    RouteModel? route,
    double? remainingDistance,
    Duration? eta,
  }) {
    return NavigationState(
      status: status ?? this.status,
      route: route ?? this.route,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      eta: eta ?? this.eta,
    );
  }

  factory NavigationState.initial() {
    return const NavigationState(
      status: NavigationStatus.idle,
    );
  }
}