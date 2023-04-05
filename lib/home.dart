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
import 'package:permission_handler/permission_handler.dart';

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
  static LatLng _kMapCenter = LatLng(51.6156036, -3.9811275);
  static CameraPosition _kInitialPosition =
      CameraPosition(target: _kMapCenter, zoom: 12.0, tilt: 0, bearing: 0);

  Set<Marker> markers = {};
  int _futureBuilderKey = 0;
  Timer? _timer;

  late Future<String> _futureCameraPosition; //备用异步方法
  late Future<List<Event>> _futureEventAndTag;

  //late List<EventTag> eventTagList;
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
    _futureCameraPosition = getUserLocation();
    _futureEventAndTag = getEventAndTag();
    //getEventTag();

  }

  @override
  void dispose() {
    //取消自动刷新
    _timer?.cancel();
    super.dispose();
  }

  //实测在IOS中会导致闪退问题
  Future<void> requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      // 位置权限已经授予，可以开始访问位置信息
    } else {
      // 位置权限被拒绝
      Future.delayed(Duration(milliseconds: 500), () {
        SystemNavigator.pop();
        exit(0);
      });
    }
  }

  //这个是一个闲置方法，可以更改方法名实现异步功能
  //这个方法会执行异步加载
  Future<String> getUserLocation() async{
    //Position position = await getLocation();
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high).timeout(Duration(seconds: 2), onTimeout: () {
    //   print("Geolocator.getCurrentPosition timed out.");
    //   return
    //     Position(longitude: 51.6156036, latitude: -3.9811275, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
    // });
    // double lat = position.latitude;
    // double lng = position.longitude;
    // LatLng kMapCenter = LatLng(lat, lng);
    // CameraPosition gainUserPosition =
    // CameraPosition(target: kMapCenter, zoom: 2.0, tilt: 0, bearing: 0);
    // setState(() {
    //   _kInitialPosition = gainUserPosition;
    // });
    return '';
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
    //这里会实现页面刷新操作，当从任何界面返回的时候，刷新页面
    _futureBuilderKey++;
    _futureCameraPosition = getUserLocation();
    _futureEventAndTag = getEventAndTag();
  }


  //使用http获取event
  Future<List<Event>> getEvent() async {
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/event/getAllEvent";
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/event/getAllEvent";
    }
    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    List<Event> eventList = (json.decode(response.body) as List<dynamic>)
        .map((dynamic item) => Event.fromJson(item))
        .toList();
    //print(eventList.length);
    return eventList;
  }

  //获取用户定位，超时时间为2秒
  //若超时，返回默认的地址
  Future<Position> getLocation() async{
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium).timeout(Duration(seconds: 2), onTimeout: () {
      print("Geolocator.getCurrentPosition timed out.");
      return
        Position(longitude: 51.6156036, latitude: -3.9811275, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
    });
    return position;
  }


  Future<List<Event>> getEventAndTag() async {
    //获取用户定位
    Position position = await getLocation();
    double lat = position.latitude;
    double lng = position.longitude;
    //将获取到的用户定位赋值给gainUserPosition
    LatLng kMapCenter = LatLng(lat, lng);
    CameraPosition gainUserPosition =
    CameraPosition(target: kMapCenter, zoom: 13.0, tilt: 0, bearing: 0);
    //获取事件和标签
    num scope = await GlobalVariable.getUserScope();
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/event/getEventAroundMe"
          + "/" + lat.toString() + "/" + lng.toString() + "/" + scope.toString();
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/event/getEventAroundMe"
          + "/" + lat.toString() + "/" + lng.toString() + "/" + scope.toString();
    }
    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    setState(() {
      //更新全局变量_kInitialPosition，根据用户坐标定位
      _kInitialPosition = gainUserPosition;
    });
    if(response.statusCode == 204){
      //返回204代码，无内容
      List<Event> eventList = [];
      return eventList;
    } else if (response.statusCode == 200){
      //返回200OK，有内容
      List<Event> eventList = (json.decode(response.body) as List<dynamic>)
          .map((dynamic item) => Event.fromJson(item))
          .toList();
      return eventList;
    } else {
      //其他事件，返回空列表
      List<Event> eventList = [];
      return eventList;
    }
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
  //备用的方法，测试用
  Future<List<EventTag>> getEventTag() async {
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/tag/getAllTag";
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/tag/getAllTag";
    }
    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    if(response.statusCode == 200){
      List<EventTag> eventTagList = (json.decode(response.body) as List<dynamic>)
          .map((dynamic item) => EventTag.fromJson(item))
          .toList();
      return eventTagList;
    } else {
      List<EventTag> eventTagList = [];
      return eventTagList;
    }
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
          heightFactor: 3 / 4, // 占据屏幕的 3/4
          child: EventDetailsPage(event: event),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
      return FutureBuilder(
      key: ValueKey(_futureBuilderKey),
      //future: getEventAndTag(),
        // 设定Future builder的方法
        future: Future.wait([_futureEventAndTag, _futureCameraPosition]),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) { //如果异步函数中存在数据
          List<Event> fetchedEventAndTag = snapshot.data![0] as List<Event>;
          //CameraPosition initialPosition = snapshot.data![1] as CameraPosition;
          //_kInitialPosition = initialPosition;
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
                      //因为上面的异步方法FutureBuilder中，获取数据的操作是和值绑定起来的
                      //所以就算更新了_futureBuilderKey，也只会让地图刷新而已
                      //想要实现数据更新，就需要重新获取一下_futureCameraPosition 和 _futureEventAndTag
                      _futureCameraPosition = getUserLocation();
                      _futureEventAndTag = getEventAndTag();
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
