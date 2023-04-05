import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Event.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:http/http.dart' as http;

import 'myEventEdit.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [];

  //使用http获取event
  Future<void> getEvent() async {
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/event/getEventWithUserId/";
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/event/getEventWithUserId/";
    }
    url += FirebaseAuth.instance.currentUser!.uid;
    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    List<Event> eventList = (json.decode(response.body) as List<dynamic>)
        .map((dynamic item) => Event.fromJson(item))
        .toList();
    if (eventList.isNotEmpty) {
      setState(() {
        events = eventList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getEvent();
  }

  Text eventStatus(Event event) {
    String returnEventTitle = '';
    Color returnEventColor = Colors.red;
    if (event.isEventExpired()) {
      //事件已经过期
      returnEventTitle = 'myEventList_expired'.tr(args: [event.eventExpireTime]);
      //color保持默认红色
    } else if (!event.isEventStarted()) {
      //事件尚未过期，尚未开始
      returnEventTitle = 'myEventList_start_at'.tr(args: [event.eventTime]);
      returnEventColor = Colors.orange;
    } else {
      //事件尚未过期，已经开始
      returnEventTitle = 'myEventList_in_progress'.tr(args: [event.eventExpireTime]);
      returnEventColor = Colors.green;
    }
    return Text(
      returnEventTitle,
      style: TextStyle(
        color: returnEventColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('myEventList_title'.tr()),
      ),
      body: events.isEmpty
          ? Center(
              child: Text('myEventList_event_empty'.tr()),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (BuildContext context, int index) {
                Event event = events[index];
                //bool isExpired = event.isEventExpired();
                return Card(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyEventEdit(event: event)),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(event.eventName),
                          subtitle:
                              Text('myEventList_create_at'.tr(args: [event.eventPublishTime])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: eventStatus(event),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
