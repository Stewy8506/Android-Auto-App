import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final StreamController<Position> _controller =
      StreamController.broadcast();

  Stream<Position> get stream => _controller.stream;

  StreamSubscription<Position>? _sub;

  Future<void> init() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception("Location services disabled");
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permanently denied");
    }
  }

  void start() {
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen(_controller.add);
  }

  void stop() {
    _sub?.cancel();
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}