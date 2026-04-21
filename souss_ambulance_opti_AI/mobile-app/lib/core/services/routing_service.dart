import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Fetches a route between two points using OSRM API.
  /// Returns a list of LatLng points representing the path.
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final String url = '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    try {
      print('Fetching route: $url');
      final response = await http.get(Uri.parse(url));
      print('Route status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok') {
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          final points = coordinates.map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble())).toList();
          print('Route found: ${points.length} points');
          return points;
        }
      }
      print('Route failed: ${response.body}');
      return [];
    } catch (e) {
      print('Routing error: $e');
      return [];
    }
  }
}
