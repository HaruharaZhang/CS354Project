import 'dart:async';
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

  Set<Marker> markers = {};
  int _futureBuilderKey = 0;
  Timer? _timer;

  //late Future<List<Event>> eventListFuture;
  //List<Event> eventList = [];
  //Set<Marker> mapMarkers = {};


  @override
  void initState() {
    super.initState();
    //设定每一分钟刷新一次
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        _futureBuilderKey++;
      });
    });
  }

  @override
  void dispose() {
    //取消自动刷新
    _timer?.cancel();
    super.dispose();
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

  void freshEvent(){
    List<Event> eventList = getEvent() as List<Event>;
    setState(() {
      markers.clear();
      for (final element in eventList) {
        final marker = Marker(
          markerId: MarkerId(element.eventId.toString()),
          position: LatLng(double.parse(element.eventLat),
              double.parse(element.eventLng)),
          infoWindow: InfoWindow(
              title: element.eventName, snippet: element.eventDesc),
        );
        markers.add(marker);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
      return FutureBuilder<List<Event>>(
      key: ValueKey(_futureBuilderKey),
      future: getEvent(), //设定Future builder的方法
      builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
        if (snapshot.hasData) { //如果异步函数中存在数据
          //marker.add(Marker(markerId: MarkerId("something")));
          //print(snapshot.toString());
          //使用foreach遍历，并且将数据存到marker中
          snapshot.data!.forEach((element) {
            //print(element.eventDesc);
            markers.add(Marker(
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
                  icon: Icon(Icons.refresh), //刷新按钮
                  onPressed: () {
                    setState(() {
                      _futureBuilderKey++;
                    });
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
                  markers: markers,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
