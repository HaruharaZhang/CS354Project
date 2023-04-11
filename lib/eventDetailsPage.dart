import 'dart:io';
import 'package:http/http.dart' as http;

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

class _EventDetailsPageState extends State<EventDetailsPage>
    with TickerProviderStateMixin {
  String? _address;
  String? _expireDate;

  bool _isLiked = false;
  int _likes = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  void initState() {
    super.initState();
    getAddress();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(_animationController);
    getLikeCount();
  }

  //将经纬度转换为地址信息
  Future<void> getAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        double.parse(widget.event.eventLat),
        double.parse(widget.event.eventLng));
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

  //事件是否已经过期
  bool isEventExpired(String endTimeStr) {
    DateTime endTime = DateTime.parse(endTimeStr);
    if (endTime.isAfter(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }

  //事件是否已经开始
  bool isEventStarted(String startTimeStr) {
    DateTime startTime = DateTime.parse(startTimeStr);
    if (startTime.isAfter(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getLikeCount() async {
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/event/get/like/";
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/event/get/like/";
    }
    url = url + widget.event.eventId.toString();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _likes = int.parse(response.body);
      });
    }
  }

  Future<void> likeEvent() async {
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/event/post/like/";
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/event/post/like/";
    }
    url = url + widget.event.eventId.toString();
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      getLikeCount();
    }
  }

  Future<void> unLikeEvent() async {
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/event/post/unlike/";
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/event/post/unlike/";
    }
    url = url + widget.event.eventId.toString();
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      getLikeCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('eventDetailsPage_title'.tr()),
        ),
        body: Stack(
          children: [
            //翻译按钮
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  // 处理按钮点击事件
                },
                child: Icon(Icons.translate),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
            //Event原文
            Padding(
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
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'eventDetailsPage_event_by'.tr(),
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: '${widget.event.eventAuth}',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        TextSpan(
                          text: 'eventDetailsPage_event_at'
                              .tr(args: [widget.event.eventPublishTime]),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value,
                            child: IconButton(
                              icon: Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isLiked ? Colors.pink : null,
                              ),
                              color:
                                  _animation.value > 1.0 ? Colors.pink : null,
                              onPressed: () {
                                setState(() {
                                  if (_isLiked) {
                                    unLikeEvent();
                                    _isLiked = false;
                                  } else {
                                    //_likes++;
                                    likeEvent();
                                    _isLiked = true;
                                  }
                                });
                                _animationController.reset();
                                _animationController.forward();
                              },
                            ),
                          );
                        },
                      ),
                      Text(_likes.toString()),
                    ],
                  ),

                  if (isEventStarted(widget.event.eventTime))
                    Text(
                      'eventDetailsPage_event_start_at'
                          .tr(args: [widget.event.eventTime]),
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),

                  if (isEventExpired(widget.event.eventExpireTime))
                    if (!isEventStarted(widget.event.eventTime))
                      Text(
                        'eventDetailsPage_event_started'.tr(),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18.0,
                        ),
                      ),

                  if (isEventExpired(widget.event.eventExpireTime))
                    Text(
                      'eventDetailsPage_event_expire_in'
                          .tr(args: [widget.event.eventExpireTime]),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.0,
                      ),
                    ),

                  if (!isEventExpired(widget.event.eventExpireTime))
                    Text(
                      'eventDetailsPage_event_expired'.tr(),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18.0,
                      ),
                    ),

                  SizedBox(height: 8.0),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'eventDetailsPage_event_address'.tr(),
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: _address,
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.0),

                  //添加一条横线以分割内容
                  Divider(
                    color: Colors.grey, // 横线颜色
                    thickness: 1.5, // 横线粗细
                    indent: 5, // 横线左侧缩进距离
                    endIndent: 5, // 横线右侧缩进距离
                  ),

                  SizedBox(height: 12.0),
                  Text(
                    'eventDetailsPage_event_desc_title'.tr(),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    widget.event.eventDesc,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),

                  SizedBox(height: 20.0),
                  Text(
                    'eventDetailsPage_event_message_title'.tr(),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    widget.event.eventMsg,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
