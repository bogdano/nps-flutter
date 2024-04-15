import 'package:flutter/material.dart';

class ParkCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final double distance; // Assume distance is passed in meters
  final String state;

  const ParkCard({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.distance,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final distanceInMiles =
        (distance / 1609.34).toStringAsFixed(1); // Convert meters to miles

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 200.0,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (distance > 0) // Check if distance is valid
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.lime[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.lime[200]!),
                    ),
                    child: Text(
                      "$distanceInMiles miles from here",
                      style: TextStyle(
                        color: Colors.lime[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  state,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
