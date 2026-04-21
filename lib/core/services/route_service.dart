import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/route_model.dart';

class RouteService {
  late final String _apiKey;

  RouteService() {
    _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  Future<RouteModel> fetchRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json"
      "?origin=$startLat,$startLng"
      "&destination=$endLat,$endLng"
      "&key=$_apiKey"
      "&mode=driving"
      "&alternatives=true",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch route");
    }

    final data = jsonDecode(response.body);

    if (data["routes"].isEmpty) {
      throw Exception("No routes found");
    }

    final routes = data["routes"] as List;
    final route = routes[0]; // primary route (best)
    final leg = route["legs"][0];

    // Parse steps and stitch high-precision geometry
    List<RouteStep> parsedSteps = [];
    List<List<double>> highResPoints = [];
    if (leg["steps"] != null) {
      for (var step in leg["steps"]) {
        final htmlInstruction = step["html_instructions"] ?? "";
        // Clean HTML tags from instruction
        final cleanInstruction = htmlInstruction.replaceAll(
          RegExp(r'<[^>]*>'),
          '',
        );

        final stepDistance = step["distance"]["value"].toDouble();
        final stepDuration = step["duration"]["value"].toDouble();
        final stepPolyline = _decodePolyline(step["polyline"]["points"]);

        // Accumulate high-res geometry to perfectly fit road curves
        highResPoints.addAll(stepPolyline);

        parsedSteps.add(
          RouteStep(
            instruction: cleanInstruction,
            distance: stepDistance,
            duration: stepDuration,
            polyline: stepPolyline,
          ),
        );
      }
    }
    
    return RouteModel(
      distance: leg["distance"]["value"].toDouble(), // meters
      duration: leg["duration"]["value"].toDouble(), // seconds
      polyline: highResPoints,
      steps: parsedSteps,
    );
  }

  List<List<double>> _decodePolyline(String encoded) {
    List<List<double>> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add([lat / 1e5, lng / 1e5]);
    }

    return poly;
  }
}
