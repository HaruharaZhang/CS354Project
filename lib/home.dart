import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'Event.dart';
import 'createNewEvent.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => MapBody();
}

class MapBody extends State<MapPage> {
  //原始位置 - Swansea
  static final LatLng _kMapCenter = LatLng(51.6156036, -3.9811275);

  static final CameraPosition _kInitialPosition =
      CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);

  //late Future<List<Event>> eventListFuture;
  //List<Event> eventList = [];
  //Set<Marker> mapMarkers = {};


  @override
  void initState() {
    super.initState();
    //eventListFuture = getEvent();
  }

  Future<List<Event>> getEvent() async {
    String url = "http://127.0.0.1:8080/webapi/event_server/event/getAllEvent";
    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    List<Event> eventList = (json.decode(response.body) as List<dynamic>)
        .map((dynamic item) => Event.fromJson(item))
        .toList();
    //print(eventList.length);
    return eventList;
  }

  void addBtnPress(){

  }

  // Future<Set<Marker>> createMarker() async {
  //   eventList = await getEvent();
  //
  //   Set<Marker> markers = eventList
  //       .map((event) => Marker(
  //             markerId: MarkerId(event.eventId.toString()),
  //             position: LatLng(
  //                 double.parse(event.eventLat), double.parse(event.eventLng)),
  //             infoWindow:
  //                 InfoWindow(title: event.eventName, snippet: event.eventDesc),
  //           ))
  //       .toSet();
  //   setState(() {
  //     eventList = eventList;
  //   });
  //   return markers;
  // }

  @override
  Widget build(BuildContext context) {
    Set<Marker> marker = {};
    return FutureBuilder<List<Event>>(
      future: getEvent(), //设定Future builder的方法
      builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
        if (snapshot.hasData) { //如果异步函数中存在数据
          //marker.add(Marker(markerId: MarkerId("something")));
          //print(snapshot.toString());
          //使用foreach遍历，并且将数据存到marker中
          snapshot.data!.forEach((element) {
            //print(element.eventDesc);
            marker.add(Marker(
              markerId: MarkerId(element.eventId.toString()),
              position: LatLng(double.parse(element.eventLat),
                  double.parse(element.eventLng)),
              infoWindow: InfoWindow(
                  title: element.eventName, snippet: element.eventDesc),
            ));
          });
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) { //处理异步操作的抱错
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Events for Me'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add), //添加event 按钮
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateNewEventPage(),
                        ));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications), //通知按钮
                  onPressed: () {

                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings), //设定按钮
                  onPressed: () {

                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _kInitialPosition,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  compassEnabled: true,
                  myLocationEnabled: true,
                  markers: marker,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
