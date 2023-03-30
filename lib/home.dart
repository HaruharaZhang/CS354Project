import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs354_project/EventTag.dart';
import 'package:cs354_project/setting.dart';
import 'package:cs354_project/Event.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'Event.dart';
import 'GlobalVariable.dart';
import 'createNewEvent.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';

import 'eventDetailsPage.dart';

//添加一个event 过期的提示
//WAZE？
//添加一个提示，如果用户有这方面的需求之类的
//或者可以问问发布者，问问event是否还在
//如果没时间的话，可以在后面提出来
//在显示的时候可以显示周围的地址
//lat -> address
class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => MapBody();
}

class MapBody extends State<MapPage> {
  late GoogleMapController _mapcontroller;
  //原始位置 - Swansea
  static final LatLng _kMapCenter = LatLng(51.6156036, -3.9811275);

  static final CameraPosition _kInitialPosition =
      CameraPosition(target: _kMapCenter, zoom: 12.0, tilt: 0, bearing: 0);

  Set<Marker> markers = {};
  int _futureBuilderKey = 0;
  Timer? _timer;

  //late Future<List<Event>> eventListFuture;
  //List<Event> eventList = [];
  //Set<Marker> mapMarkers = {};
  //bool _isAutoRefreshEnabled = true;
  late List<EventTag> eventTagList;
  late final busIconByte;
  late final trafficJamIconByte;
  late final carAccidentIconByte;
  late final somethingCoolIconByte;
  late final unknownIconByte;



  @override
  void initState() {
    super.initState();
    loadIcon();
    getAutoRefresh();
    getEventTag();
  }

  @override
  void dispose() {
    //取消自动刷新
    _timer?.cancel();
    super.dispose();
  }

  //从全局变量中获取数据
  Future<void> getAutoRefresh() async {
    //异步方法获取数据
    bool returnValue = await GlobalVariable.getAutoRefreshEnable();
    setState(() {
      //为true时，设置timer并且自动刷新
      if(returnValue){
        Fluttertoast.showToast(
          msg: 'home_enable_auto_refresh'.tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM, // 设置Toast在屏幕底部显示
          timeInSecForIosWeb: 2,
          fontSize: 16.0,
        );
        _timer = Timer.periodic(Duration(minutes: 1), (timer) {
          setState(() {
            _futureBuilderKey++;
          });
        });
        //为false时，尝试关闭timer
      } else {
        Fluttertoast.showToast(
          msg: 'home_disable_auto_refresh'.tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM, // 设置Toast在屏幕底部显示
          timeInSecForIosWeb: 2,
          fontSize: 16.0,
        );
        _timer?.cancel();
      }
    });
  }


  //使用http获取event
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

  Future<List<Event>> getEventAndTag() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double lng = position.longitude;
    num scope = await GlobalVariable.getUserScope();
    String url = "http://127.0.0.1:8080/webapi/event_server/event/getEventAroundMe"
    + "/" + lat.toString() + "/" + lng.toString() + "/" + scope.toString();
    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    List<Event> eventList = (json.decode(response.body) as List<dynamic>)
        .map((dynamic item) => Event.fromJson(item))
        .toList();
    return eventList;
  }

  //刷新event
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

  //使用http获取event的tag
  Future<List<EventTag>> getEventTag() async {
    String url = "http://127.0.0.1:8080/webapi/event_server/tag/getAllTag";
    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    List<EventTag> eventTagList = (json.decode(response.body) as List<dynamic>)
        .map((dynamic item) => EventTag.fromJson(item))
        .toList();
    return eventTagList;
  }


  //加载图标，将其保存在全局变量之中
  Future<void> loadIcon() async {
    busIconByte = await rootBundle.load("assets/icon/bus_icon_64px.png");
    trafficJamIconByte = await rootBundle.load("assets/icon/traffic_jam_icon_64px.png");
    carAccidentIconByte = await rootBundle.load("assets/icon/car_accident_icon_64px.png");
    somethingCoolIconByte = await rootBundle.load("assets/icon/something_cool_icon_64px.png");
    unknownIconByte = await rootBundle.load("assets/icon/unknown_icon_64px.png");
  }

  //根据不同的tag输出不同的图标
  BitmapDescriptor addEventIcon(String tag) {
    //print(tag);
    switch (tag) {
      case "Bus Problem":
        Uint8List iconUnit = busIconByte.buffer.asUint8List();
        final BitmapDescriptor markerIcon =
        BitmapDescriptor.fromBytes(iconUnit);
        return markerIcon;
      case "Traffic jam":
        Uint8List iconUnit = trafficJamIconByte.buffer.asUint8List();
        final BitmapDescriptor markerIcon =
        BitmapDescriptor.fromBytes(iconUnit);
        return markerIcon;
      case "Car accident":
        Uint8List iconUnit = carAccidentIconByte.buffer.asUint8List();
        final BitmapDescriptor markerIcon =
        BitmapDescriptor.fromBytes(iconUnit);
        return markerIcon;
      case "Something Cool":
        Uint8List iconUnit = somethingCoolIconByte.buffer.asUint8List();
        final BitmapDescriptor markerIcon =
        BitmapDescriptor.fromBytes(iconUnit);
        return markerIcon;
      default:
        Uint8List iconUnit = unknownIconByte.buffer.asUint8List();
        final BitmapDescriptor markerIcon =
        BitmapDescriptor.fromBytes(iconUnit);
        return markerIcon;
    }
    //final byteData = await rootBundle.load("assets/icon/bus_icon_512px.png");
    Uint8List iconUnit = busIconByte.buffer.asUint8List();
    final BitmapDescriptor markerIcon =
    BitmapDescriptor.fromBytes(iconUnit);
    return markerIcon;
  }

  void _showEventDetailsModalBottomSheet(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许用户滚动
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 2 / 3, // 占据屏幕的 2/3
          child: EventDetailsPage(event: event),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
      return FutureBuilder(
      key: ValueKey(_futureBuilderKey),
      future: getEventAndTag(), //设定Future builder的方法
      builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) { //如果异步函数中存在数据
          List<Event> fetchedEventAndTag = snapshot.data! as List<Event>;
          markers.clear(); //这个要先清空markers，然后重新加载
          //使用foreach遍历，并且将数据存到events中
          fetchedEventAndTag.forEach((events) {
            markers.add(Marker(
              markerId: MarkerId(events.eventId.toString()),
              position: LatLng(double.parse(events.eventLat),
                  double.parse(events.eventLng)),
              infoWindow: InfoWindow(
                  title: events.eventName, snippet: events.eventDesc),
              icon: addEventIcon(events.eventTag),
              onTap: () {
                Vibration.vibrate(duration: 300); // 触发震动
                _showEventDetailsModalBottomSheet(context, events); // 显示 EventDetailsPage，并传递事件参数
              },
            ));
          });

          // List<Event> fetchedEvent = snapshot.data![0] as List<Event>;
          // List<EventTag> fetchedEventTag = snapshot.data![1] as List<EventTag>;
          // //使用foreach遍历，并且将数据存到events中
          // fetchedEvent.forEach((events) {
          //   for(EventTag tags in fetchedEventTag){
          //     if(events.eventId == tags.eventId){
          //       markers.add(Marker(
          //         markerId: MarkerId(events.eventId.toString()),
          //         position: LatLng(double.parse(events.eventLat),
          //             double.parse(events.eventLng)),
          //         infoWindow: InfoWindow(
          //             title: events.eventName, snippet: events.eventDesc),
          //         icon: addEventIcon(tags.eventTag),
          //       ));
          //       break;
          //     }
          //   }
          // });
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
              title: Text("home_title".tr()),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add), //添加event 按钮
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateNewEventPage(),
                        )).then((value) => getAutoRefresh());
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingPage(),
                          //下面的then方法中，当页面返回的时候重新call一次
                          //getAutoRefresh()方法以实现数据更新
                        )).then((value) => getAutoRefresh());
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _kInitialPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _mapcontroller = controller;
                  },
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
