import 'package:flutter/material.dart';
import 'parks_list.dart';
import 'location_search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'sign_in_with_google.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY']!,
          authDomain: "nps-react.firebaseapp.com",
          projectId: "nps-react",
          storageBucket: "nps-react.appspot.com",
          messagingSenderId: "994868514646",
          appId: "1:994868514646:web:3e2be489a5e333ca7a50f7",
          measurementId: "G-RPYJL60Q0H"));
  runApp(const NationalParksFinderApp());
}

class NationalParksFinderApp extends StatefulWidget {
  const NationalParksFinderApp({super.key});

  @override
  _NationalParksFinderAppState createState() => _NationalParksFinderAppState();
}

class _NationalParksFinderAppState extends State<NationalParksFinderApp> {
  List<double>? startLocation;
  String locationName = '';

  void handleLocationSelect(List<double> location, String name) {
    setState(() {
      startLocation = location;
      locationName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'National Parks Finder',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14.0),
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          backgroundColor: Colors.orange[300],
          title: const Text(
            'National Parks Finder',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          // This Column is now non-scrollable
          children: <Widget>[
            LocationSearch(onLocationSelect: handleLocationSelect),
            if (locationName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Parks closest to $locationName:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            Expanded(
              // Using Expanded to fill the remaining space with the ParksList
              child: startLocation != null
                  ? ParksList(startLocation: startLocation!)
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Please select a start location to see the closest national parks.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
            ),
            // Optionally include other widgets here
          ],
        ),
      ),
    );
  }
}
