class RouteModel {
  /// Total distance in meters
  final double distance;

  /// Total duration in seconds
  final double duration;

  /// List of lat/lng points for drawing polyline
  final List<List<double>> polyline;

  /// Optional: step-by-step navigation (future use)
  final List<RouteStep>? steps;

  RouteModel({
    required this.distance,
    required this.duration,
    required this.polyline,
    this.steps,
  });

  double get distanceKm => distance / 1000;

  Duration get durationTime => Duration(seconds: duration.round());

  String get formattedDistance =>
      "${distanceKm.toStringAsFixed(1)} km";

  String get formattedDuration =>
      "${durationTime.inMinutes} min";
}

class RouteStep {
  final String instruction;
  final double distance;
  final double duration;
  final List<List<double>> polyline; // Points forming this step

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.polyline,
  });
}