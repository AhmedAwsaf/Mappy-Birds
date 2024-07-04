import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class TvShowScreen extends StatefulWidget {
  @override
  _TvShowScreenState createState() => _TvShowScreenState();
}

class _TvShowScreenState extends State<TvShowScreen> {
  late Future<List<DataModel>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchPosts();
  }

  Future<List<DataModel>> fetchPosts() async {
    final response =
        await http.get(Uri.https("labs.anontech.info", "/cse489/t3/api.php"));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DataModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data List'),
      ),
      body: Center(
        child: FutureBuilder<List<DataModel>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  return ListTile(
                    title: Text(data.title),
                    subtitle: Text('Lat: ${data.lat}, Lon: ${data.lon}'),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data.imageUrl),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditScreen(data: data),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class DataModel {
  final int id;
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
      id: json['id'],
      title: json['title'],
      lat: json['lat'],
      lon: json['lon'],
      imageUrl: baseUrl + json['image'], // Construct full URL
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'image':
          imageUrl, // Assuming image URL is used as a placeholder for the file
    };
  }
}

class EditScreen extends StatefulWidget {
  final DataModel data;

  EditScreen({required this.data});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  late TextEditingController _imageController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data.title);
    _latController = TextEditingController(text: widget.data.lat.toString());
    _lonController = TextEditingController(text: widget.data.lon.toString());
    _imageController = TextEditingController(text: widget.data.imageUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveData() async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.https('labs.anontech.info', '/cse489/t3/api.php'),
    );

    request.fields['id'] = widget.data.id.toString();
    request.fields['title'] = _titleController.text;
    request.fields['lat'] = _latController.text;
    request.fields['lon'] = _lonController.text;

    if (_imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Data updated successfully');
    } else {
      print('Failed to update data');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _latController,
              decoration: InputDecoration(labelText: 'Lat'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _lonController,
              decoration: InputDecoration(labelText: 'Lon'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
