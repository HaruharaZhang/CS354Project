import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'Event.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => Home();
}

class Home extends State<HomePage> {
  static final LatLng _kMapCenter =
  LatLng(51.6156036, -3.9811275);

  static final CameraPosition _kInitialPosition =
  CameraPosition(target: _kMapCenter, zoom: 13.0, tilt: 0, bearing: 0);


  @override
  void initState() {
    super.initState();
    getEvent();
  }

  getEvent() async {
    String url = "http://127.0.0.1:8080/webapi/event_server/event/getAllEvent";
    // HttpClient httpClient = HttpClient();
    // HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    // HttpClientResponse response = await request.close();
    // print(response.statusCode);
    // var result = await response.transform(utf8.decoder).join();
    // print(result);
    // httpClient.close();

    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    //print(response.body);

    List<dynamic> responseEvent = jsonDecode(response.body);

    print(responseEvent);

    print(responseEvent.length);

    print(responseEvent[0]);

    Event event = responseEvent[0];
    print(event.eventId);

    // List<Marker> markers = <Marker>[];
    // for (int i = 0; i < responseEvent.length; i++){
    //   Event event = responseEvent[i];
    //   markers.add(
    //       Marker(markerId: MarkerId(event.eventName as String))
    //   );
    // }


    //return responseEvent;

    //如果Events为空，返回false
    // if(responseEvent.isEmpty) {
    //   return null;
    // } else {
    //   return responseEvent;
    // }
    // Event event = responseEvent[0];
    // event.eventId;
  }




  Set<Marker> _createMarker() {
    //var eventList = getEvent() as Future<dynamic>;
    //List<Marker> _markers = <Marker>[];
    //print(eventList);
    // eventList.then((event) {
    //   Event event = eventList as Event;
    //
    //   // _markers.add(
    //   //   Marker(markerId: event.eventId)
    //   // )
    //
    // });
    // if(responseEventList.isEmpty){
    //   //TODO 输出一些提示说明没有events
    // } else {
    //
    // }

    return {
      Marker(
          markerId: MarkerId("test mark 1"),
          position: _kMapCenter,
          infoWindow: InfoWindow(title: 'Marker 1')
      ),
      Marker(
        markerId: MarkerId("test mark 2"),
        position: LatLng(51.6256036, -3.9911275),
      ),
    };
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Home Page")),
        body:GoogleMap(
          initialCameraPosition: _kInitialPosition,
          myLocationEnabled: true,
          markers: _createMarker(),
        ),
    );
  }
}
