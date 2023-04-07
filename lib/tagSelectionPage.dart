import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TagSelectionPage extends StatefulWidget {
  @override
  _TagSelectionPageState createState() => _TagSelectionPageState();
}

class _TagSelectionPageState extends State<TagSelectionPage> {
  @override
  void initState() {
    super.initState();
    getUserCity();
  }

  List<String> selectedTags = [];
  List<String> allTags = [
    'Bus Problem',
    'Traffic jam',
    'Car accident',
    'Something Cool',
    'Others'
  ];
  String userCity = "";
  final cityInputController = TextEditingController();

  Future<void> getUserCity() async {
    Position position = await getLocation();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      userCity = place.locality!;
    });
  }

  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium)
        .timeout(Duration(seconds: 2), onTimeout: () {
      print("Geolocator.getCurrentPosition timed out.");
      return Position(
          longitude: 51.6156036,
          latitude: -3.9811275,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,
          speedAccuracy: 1);
    });
    return position;
  }

  Future<bool> _uploadTag() async {
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/user/subscribe/tag/";
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/user/subscribe/tag/";
    }
    url += '${await FirebaseMessaging.instance.getToken()}/$userCity/$selectedTags';
    print(url);
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error sending data with error response code: ' +
          response.statusCode.toString());
      return false;
    }
  }

  void changeCity() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Input your City"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            TextFormField(
              controller: cityInputController,
              decoration: InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => {
              setState(() {
                userCity = cityInputController.text;
              }),
              Navigator.of(context).pop(),
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tag Selection'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Please select one or more tags:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allTags.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(allTags[index]),
                  value: selectedTags.contains(allTags[index]),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        selectedTags.add(allTags[index]);
                      } else {
                        selectedTags.remove(allTags[index]);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Text(
            'Your city: $userCity',
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
          GestureDetector(
            onTap: changeCity,
            child: Text(
              'Change',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.blue,
                  decoration: TextDecoration.underline),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[200],
            ),
            child: Text(
              'When you submit, you will receive a notification when a '
              'user in your city posts a new event with the tags you selected',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: ElevatedButton(
              onPressed: selectedTags.isEmpty
                  ? null
                  : () {
                      _uploadTag();
                      Navigator.of(context).pop();
                    },
              child: Text('Submit', style: TextStyle(fontSize: 15.0)),
            ),
          ),
          SizedBox(height: 30.0),
        ],
      ),
    );
  }
}
