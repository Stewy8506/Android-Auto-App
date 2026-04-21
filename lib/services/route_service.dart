import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/route_model.dart';

class RouteService {
  static const String _apiKey = "AIzaSyBQzUJMcehvlc14DeEkAaW6MQd7HxG7fa0";

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
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch route");
    }

    final data = jsonDecode(response.body);

    if (data["routes"].isEmpty) {
      throw Exception("No routes found");
    }

    final route = data["routes"][0];
    final leg = route["legs"][0];

    return RouteModel(
      distance: leg["distance"]["value"].toDouble(), // meters
      duration: leg["duration"]["value"].toDouble(), // seconds
      polyline: _decodePolyline(route["overview_polyline"]["points"]),
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

      poly.add([lat / 1E5, lng / 1E5]);
    }

    return poly;
  }
}