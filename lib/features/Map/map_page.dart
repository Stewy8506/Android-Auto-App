import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'map_view_model.dart';
import '../Navigation/navigation_controller.dart';
import '../../core/models/navigation_state.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<MapViewModel>();
      vm.fetchCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    final nav = context.watch<NavigationController>().state;

    return Scaffold(
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.currentPosition == null
          ? const Center(child: Text("Location unavailable"))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      vm.currentPosition!.latitude,
                      vm.currentPosition!.longitude,
                    ),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  polylines: _buildPolylines(nav),
                  onMapCreated: (controller) async {
                    _mapController = controller;

                    // Move camera to user location smoothly
                    final vm = context.read<MapViewModel>();
                    if (vm.currentPosition != null) {
                      await _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(
                            vm.currentPosition!.latitude,
                            vm.currentPosition!.longitude,
                          ),
                          16,
                        ),
                      );
                    }
                  },
                ),

                /// 🔘 Start Navigation Button
                if (nav.status == NavigationStatus.preview)
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: ElevatedButton(
                      onPressed: vm.startNavigation,
                      child: const Text("Start Navigation"),
                    ),
                  ),
              ],
            ),
    );
  }

  Set<Polyline> _buildPolylines(NavigationState state) {
    if (state.route == null) return {};

    final points = state.route!.polyline
        .map((p) => LatLng(p[0], p[1]))
        .toList();

    return {
      Polyline(
        polylineId: const PolylineId("route"),
        points: points,
        width: 5,
        color: Colors.blue,
      ),
    };
  }
}
