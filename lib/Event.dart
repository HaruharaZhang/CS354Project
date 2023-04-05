class Event {
  String eventAuth;
  String eventDesc;
  int eventId;
  String eventLat;
  String eventLng;
  String eventMsg;
  String eventName;
  String eventTime;
  String eventTag;
  String eventExpireTime;
  String eventPublishTime;

  Event(
      {required this.eventAuth,
      required this.eventDesc,
      required this.eventId,
      required this.eventLat,
      required this.eventLng,
      required this.eventMsg,
      required this.eventName,
      required this.eventTime,
      required this.eventTag,
      required this.eventExpireTime,
      required this.eventPublishTime});

  // Event.fromJson(Map<String, dynamic> json) {
  //   eventAuth = json['eventAuth'];
  //   eventDesc = json['eventDesc'];
  //   eventId = json['eventId'];
  //   eventLat = json['eventLat'];
  //   eventLng = json['eventLng'];
  //   eventMsg = json['eventMsg'];
  //   eventName = json['eventName'];
  //   eventTime = json['eventTime'];
  // }
  factory Event.fromJson(Map<String, dynamic> parsedJson) {
    return Event(
        eventId: parsedJson['eventId'],
        eventAuth: parsedJson['eventAuth'].toString(),
        eventDesc: parsedJson['eventDesc'].toString(),
        eventLat: parsedJson['eventLat'].toString(),
        eventLng: parsedJson['eventLng'].toString(),
        eventMsg: parsedJson['eventMsg'].toString(),
        eventName: parsedJson['eventName'].toString(),
        eventTime: parsedJson['eventTime'].toString(),
        eventTag: parsedJson['eventTag'].toString(),
        eventExpireTime: parsedJson['eventExpireAt'].toString(),
        eventPublishTime: parsedJson['eventPublishAt'.toString()]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventAuth'] = this.eventAuth;
    data['eventDesc'] = this.eventDesc;
    data['eventId'] = this.eventId;
    data['eventLat'] = this.eventLat;
    data['eventLng'] = this.eventLng;
    data['eventMsg'] = this.eventMsg;
    data['eventName'] = this.eventName;
    data['eventTime'] = this.eventTime;
    data['eventTag'] = this.eventTag;
    data['eventExpireAt'] = this.eventExpireTime;
    data['eventPublishAt'] = this.eventPublishTime;
    return data;
  }

  //事件是否已经过期
  bool isEventExpired() {
    DateTime endTime = DateTime.parse(eventExpireTime);
    if (endTime.isBefore(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }

  //事件是否已经开始
  bool isEventStarted() {
    DateTime startTime = DateTime.parse(eventTime);
    if (startTime.isBefore(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }
}
