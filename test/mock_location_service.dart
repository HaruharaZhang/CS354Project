import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class MockLocationService extends GeolocatorPlatform {
  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    return Future.value(
      Position(
        latitude: 37.421999,
        longitude: -122.084057,
        altitude: 0.0,
        accuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    // 如果需要，您可以在这里实现位置流的模拟。
    throw UnimplementedError();
  }
}
