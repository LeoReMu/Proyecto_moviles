import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapsApi {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String _apiKey = 'AIzaSyCmpvcea6-FgitxnkdXp8_gInV1XZsM_QY';

  static Future<Map<String, dynamic>> getDirections({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final Uri uri = Uri.parse(
        '$_baseUrl?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&key=$_apiKey');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener las direcciones');
    }
  }

  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      poly.add(LatLng(latitude, longitude));
    }
    return poly;
  }

  static List<LatLng> extractRouteCoordinates(
      Map<String, dynamic> directionsData) {
    List<LatLng> coordinates = [];

    List<dynamic> routes = directionsData['routes'];
    if (routes.isNotEmpty) {
      List<dynamic> legs = routes[0]['legs'];
      if (legs.isNotEmpty) {
        List<dynamic> steps = legs[0]['steps'];
        for (int i = 0; i < steps.length; i++) {
          String polyline = steps[i]['polyline']['points'];
          List<LatLng> segment = decodePolyline(polyline);
          coordinates.addAll(segment);
        }
      }
    }

    return coordinates;
  }
}
