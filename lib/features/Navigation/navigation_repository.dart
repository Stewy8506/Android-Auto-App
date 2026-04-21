import 'package:rider_app/models/route_model.dart';
import 'package:rider_app/services/route_service.dart';
import 'package:rider_app/services/location_service.dart';
import 'package:rider_app/services/navigation_service.dart';

class NavigationRepository {
  final RouteService routeService;
  final LocationService locationService;
  final NavigationService navigationService;

  NavigationRepository({
    required this.routeService,
    required this.locationService,
    required this.navigationService,
  });

  /// Fetch route from API
  Future<RouteModel> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return routeService.fetchRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );
  }

  /// Start GPS tracking
  Future<void> startLocation() async {
    await locationService.init();
    locationService.start();
  }

  void stopLocation() {
    locationService.stop();
  }

  /// Start navigation updates
  void startNavigation(RouteModel route) {
    navigationService.startNavigation(route);
  }

  void stopNavigation() {
    navigationService.stopNavigation();
  }

  /// Stream of navigation updates
  Stream<NavigationUpdate> get navigationStream =>
      navigationService.stream;

  void dispose() {
    navigationService.dispose();
    locationService.dispose();
  }
}