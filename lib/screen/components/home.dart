import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<DataModel>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchPosts();
  }

  Future<List<DataModel>> fetchPosts() async {
    final response = await http.get(Uri.parse('https://labs.anontech.info/cse489/t3/api.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DataModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
Widget build(BuildContext context) {
  return FutureBuilder<List<DataModel>>(
    future: futureData,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(23.777176, 90.399452),
            initialZoom: 15.0,
            maxZoom: 30.0,
            cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(
              LatLng(20.7433, 88.0844), // Southwest bound
              LatLng(26.6299, 92.6727), // Northeast bound
            )),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: snapshot.data!.map((dataModel) => Marker(
                point: LatLng(dataModel.lat.toDouble(), dataModel.lon.toDouble()),
                width: 120.0,
                height: 120.0,
                child: const Icon(
                    Icons.location_on,
                    color: Colors.purple,
                  ),
                
              )).toList(),
            ),
          ],
        );
      } else {
        return Center(child: Text('No data found'));
      }
    },
  );
}
}

class DataModel {
  final num id;
  final String title;
  final num lat;
  final num lon;
  final String imageUrl; // Store relative path here
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/';

  DataModel({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.imageUrl,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      id : json['id'],
      title: json['title'],
      lat: json['lat'],
      lon: json['lon'],
      imageUrl: baseUrl + json['image'], // Construct full URL
    );
  }
}