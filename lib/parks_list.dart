import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'park_card.dart';
import 'mapbox_matrix.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class ParksList extends StatefulWidget {
  final List<double> startLocation;

  const ParksList({super.key, required this.startLocation});

  @override
  _ParksListState createState() => _ParksListState();
}

class _ParksListState extends State<ParksList> {
  List<dynamic> parks = [];
  bool isLoading = false;
  String? error;

  @override
  void didUpdateWidget(covariant ParksList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startLocation != oldWidget.startLocation) {
      fetchAndDisplayClosestParks();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.startLocation.isNotEmpty) {
      fetchAndDisplayClosestParks();
    }
  }

  void fetchAndDisplayClosestParks() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('nationalParks').get();
      final parksData = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'description': data['description'],
          'imageUrl': data['images'][0],
          'state': data['state'],
          'coordinates': [
            double.parse(data['longitude']),
            double.parse(data['latitude'])
          ],
        };
      }).toList();

      final closestParks =
          await fetchDrivingDistances(widget.startLocation, parksData);

      setState(() {
        parks = closestParks.take(6).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch parks.';
        isLoading = false;
      });
      // ignore: avoid_print
      print("Error fetching or sorting parks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    if (widget.startLocation.isEmpty) {
      return Container(); // Equivalent to returning null in React
    }

    return ResponsiveGridList(
      minItemWidth: 300,
      horizontalGridSpacing: 16, // Horizontal space between grid items
      verticalGridSpacing: 16, // Vertical space between grid items
      horizontalGridMargin: 50, // Horizontal space around the grid
      verticalGridMargin: 50, // Vertical space around the grid
      minItemsPerRow:
          1, // The minimum items to show in a single row. Takes precedence over minItemWidth
      maxItemsPerRow:
          3, // The maximum items to show in a single row. Can be useful on large screens

      children: parks
          .map((park) => ParkCard(
                key: ValueKey(park['id']),
                name: park['name'],
                description: park['description'],
                imageUrl: park['imageUrl'],
                distance: park['drivingDistance'],
                state: park['state'],
              ))
          .toList(),
    );
  }
}
