class Event {
  String? eventAuth;
  String? eventDesc;
  int? eventId;
  String? eventLat;
  String? eventLng;
  String? eventMsg;
  String? eventName;
  String? eventTime;

  Event(
      {this.eventAuth,
      this.eventDesc,
      this.eventId,
      this.eventLat,
      this.eventLng,
      this.eventMsg,
      this.eventName,
      this.eventTime});

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
        eventTime: parsedJson['eventTime'].toString());
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
    return data;
  }
}
