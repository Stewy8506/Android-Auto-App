import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../Navigation/navigation_controller.dart';

class MapViewModel extends ChangeNotifier {
  final NavigationController navigationController;

  MapViewModel(this.navigationController);

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Get current location
  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    _currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Preview route (before navigation starts)
  Future<void> previewRoute({
    required double destLat,
    required double destLng,
  }) async {
    if (_currentPosition == null) return;

    _isLoading = true;
    notifyListeners();

    await navigationController.previewRoute(
      startLat: _currentPosition!.latitude,
      startLng: _currentPosition!.longitude,
      endLat: destLat,
      endLng: destLng,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Start navigation
  Future<void> startNavigation() async {
    await navigationController.startNavigation();
  }
}