import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

double haversineDistance(
    List<double> coords1, List<double> coords2, bool isMiles) {
  double toRad(double x) => x * 3.141592653589793 / 180.0;
  double R = 6371; // Earth's radius in km

  double dLat = toRad(coords2[1] - coords1[0]);
  double dLon = toRad(coords2[0] - coords1[1]);
  double lat1 = toRad(coords1[0]);
  double lat2 = toRad(coords2[1]);

  double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  double distance = R * c;

  return isMiles ? distance * 0.621371 : distance;
}

Future<List<dynamic>> fetchDrivingDistances(
    List<double> startCoordinates, List<dynamic> parksData) async {
  try {
    // Attach as-the-crow-flies distance to each park
    List<dynamic> parks = parksData.map((park) {
      return {
        ...park,
        'haversineDistance':
            haversineDistance(startCoordinates, park['coordinates'], true)
      };
    }).toList();

    // Sort by as-the-crow-flies distance and pick the top N closest for detailed calculation
    parks.sort(
        (a, b) => a['haversineDistance'].compareTo(b['haversineDistance']));
    List<dynamic> closestParks = parks.take(6).toList();
    // add start coordinates to the list
    closestParks.insert(0, {
      'coordinates': [startCoordinates[1], startCoordinates[0]],
    });

    // Prepare the API call
    String accessToken = dotenv.env['MAPBOX_API_KEY']!;
    String points = closestParks
        .map((park) => "${park['coordinates'][0]},${park['coordinates'][1]}")
        .join(';');
    String url =
        "https://api.mapbox.com/directions-matrix/v1/mapbox/driving/$points?sources=0&annotations=distance&access_token=$accessToken";

    // Fetch driving distances
    var response = await http.get(Uri.parse(url));
    // Remove the start coordinates
    closestParks.removeAt(0);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> distances =
          data['distances'][0].sublist(1); // Skip the first element
      // Attach driving distance to each park
      for (int i = 0; i < closestParks.length; i++) {
        closestParks[i]['drivingDistance'] = distances[i] as double;
      }

      // Return parks sorted by driving distance
      closestParks
          .sort((a, b) => a['drivingDistance'].compareTo(b['drivingDistance']));
      return closestParks;
    } else {
      return [];
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error fetching driving distances: $e");
    return [];
  }
}
