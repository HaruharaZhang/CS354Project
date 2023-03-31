import 'package:cs354_project/Event.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class EventDetailsPage extends StatefulWidget {

  final Event event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {

  String? _address;
  String? _expireDate;
  void initState() {
    super.initState();
    getAddress();
  }

  //将经纬度转换为地址信息
  Future<void> getAddress() async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(double.parse(widget.event.eventLat), double.parse(widget.event.eventLng));
    Placemark place = placemarks[0]; // 获取第一个地址信息
    String address;
    //如果找不到地址信息的话，使用特定字符串替代
    if (place.street == "") {
      address =
      "${"createNewEvent_new_event_unknown_street".tr()}, ${place.subLocality}, ${place.locality}, ${place.country}";
    } else {
      address =
      "${place.street} , ${place.subLocality}, ${place.locality}, ${place.country}";
    }
    setState(() {
      _address = address;
    });
  }

  Future<void> isEventExpire() async{
    //widget.event.e
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.eventName,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Auth: ${widget.event.eventAuth}',
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Publish at: ${widget.event.eventPublishTime}',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Event start at: ${widget.event.eventTime}',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Expire In: ${widget.event.eventExpireTime}',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            //${widget.event.eventLat}  ' ' ${widget.event.eventLng}
            Text(
              'Location: $_address',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description: ${widget.event.eventDesc}',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Message: ${widget.event.eventMsg}',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
