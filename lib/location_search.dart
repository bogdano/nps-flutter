import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationSearch extends StatefulWidget {
  final Function(List<double>, String) onLocationSelect;

  const LocationSearch({super.key, required this.onLocationSelect});

  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  final TextEditingController _controller = TextEditingController();

  void searchLocation() async {
    String accessToken = dotenv.env['MAPBOX_API_KEY']!;
    final query = _controller.text;
    String url = "https://api.mapbox.com/geocoding/v5/mapbox.places/"
        "$query.json?country=US&limit=5&language=en-US&types=place&access_token=$accessToken";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].length > 0) {
          final feature = data['features'][0];
          final center = feature['center'];
          final placeName = feature['text'];

          widget.onLocationSelect(
              [center[1], center[0]], placeName); // Mapbox returns [lon, lat]
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to fetch location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            onSubmitted: (_) => searchLocation(),
            decoration: InputDecoration(
              labelText: 'Enter start location',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: searchLocation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
