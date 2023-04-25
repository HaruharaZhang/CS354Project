import 'package:cs354_project/Event.dart';
import 'package:cs354_project/EventTag.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs354_project/home.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


void main() {
  final mapBody = MapBody();
  Event testEvent = Event(eventAuth: "anonymous", eventDesc: "something",
      eventId: 1, eventLat: "12.3456", eventLng: "12.3456",
      eventMsg: "someMsg", eventName: "eventName",
      eventTime: "eventTime", eventTag: "eventTag",
      eventExpireTime: "eventExpireTime", eventPublishTime: "eventPublishTime");
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test getLocation method', () async {
    final position = await mapBody.getLocation();
    expect(position, isNotNull);
    expect(position.latitude, isNotNull);
    expect(position.longitude, isNotNull);
  });

  test('Test getEventAndTag method', () async {
    final events = await mapBody.getEventAndTag();
    expect(events, isNotNull);
    expect(events, isNotEmpty);
    for (Event event in events) {
      expect(event.eventName, isNotNull);
      expect(event.eventId, isNotNull);
      expect(event.eventMsg, isNotNull);
      expect(event.eventExpireTime, isNotNull);
      expect(event.eventTime, isNotNull);
      expect(event.eventDesc, isNotNull);
      expect(event.eventLng, isNotNull);
      expect(event.eventLat, isNotNull);
      expect(event.eventPublishTime, isNotNull);
      expect(event.eventAuth, isNotNull);
      expect(event.eventTag, isNotNull);
    }
  });

  test('Test getEventTag method', () async {
    final eventTags = await mapBody.getEventTag();
    expect(eventTags, isNotNull);
    expect(eventTags, isNotEmpty);
    for (EventTag eventTag in eventTags) {
      expect(eventTag.eventId, isNotNull);
      expect(eventTag.eventTag, isNotNull);
      expect(eventTag.eventTagId, isNotNull);
    }
  });

  test('Test addEventIcon method', () async {
    final tag = "more";
    mapBody.loadIcon();
    final icon = await mapBody.addEventIcon(tag);
    expect(icon, isNotNull);
    expect(icon, isA<BitmapDescriptor>());
  });
}
