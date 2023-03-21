import 'package:flutter/cupertino.dart';

class EventTag{
  int eventTagId;
  int eventId;
  String eventTag;
  EventTag({
    required this.eventTagId,
    required this.eventId,
    required this.eventTag
  });
  factory EventTag.fromJson(Map<String, dynamic> parsedJson) {
    return EventTag(
        eventTagId: parsedJson['eventTagId'],
        eventId: parsedJson['eventId'],
        eventTag: parsedJson['eventTag'].toString());
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventTagId'] = this.eventTagId;
    data['eventId'] = this.eventId;
    data['eventTag'] = this.eventTag;
    return data;
  }
}