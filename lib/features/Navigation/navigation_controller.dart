import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../models/navigation_state.dart';
import '../../models/route_model.dart';
import '../../services/navigation_service.dart';
import 'navigation_repository.dart';

class NavigationController extends ChangeNotifier {
  final NavigationRepository repository;

  NavigationState _state = NavigationState.initial();
  NavigationState get state => _state;

  StreamSubscription<NavigationUpdate>? _navSub;

  NavigationController(this.repository);

  /// Preview route (before starting navigation)
  Future<void> previewRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final route = await repository.getRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );

    _state = NavigationState(
      status: NavigationStatus.preview,
      route: route,
      remainingDistance: route.distance,
      eta: route.durationTime,
    );

    notifyListeners();
  }

  /// Start navigation
  Future<void> startNavigation() async {
    if (_state.route == null) return;

    await repository.startLocation();
    repository.startNavigation(_state.route!);

    _navSub = repository.navigationStream.listen((update) {
      _state = _state.copyWith(
        status: NavigationStatus.navigating,
        remainingDistance: update.remainingDistance,
        eta: update.eta,
      );

      notifyListeners();
    });
  }

  /// Stop navigation
  void stopNavigation() {
    _navSub?.cancel();
    repository.stopNavigation();
    repository.stopLocation();

    _state = NavigationState.initial();
    notifyListeners();
  }

  /// Pause navigation (optional)
  void pauseNavigation() {
    _navSub?.pause();

    _state = _state.copyWith(
      status: NavigationStatus.paused,
    );

    notifyListeners();
  }

  /// Resume navigation
  void resumeNavigation() {
    _navSub?.resume();

    _state = _state.copyWith(
      status: NavigationStatus.navigating,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _navSub?.cancel();
    repository.dispose();
    super.dispose();
  }
}