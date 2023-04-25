import 'package:cs354_project/Event.dart';
import 'package:cs354_project/EventTag.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs354_project/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart' as driver;

import 'mock_location_service.dart';

void main() {
  setUpAll(() {
    // 注入自定义位置服务
    GeolocatorPlatform.instance = MockLocationService();
  });

  testWidgets('Test MapPage Widget', (WidgetTester tester) async {
    // 注入自定义位置服务
    GeolocatorPlatform.instance = MockLocationService();

    // 构建MapPage组件
    await tester.pumpWidget(MaterialApp(home: MapPage()));

    // 给异步操作更多时间
    await tester.pump(Duration.zero);
    await Future.delayed(Duration(seconds: 7));

    // 检查是否有一个app bar
    expect(find.byType(AppBar), findsOneWidget);

    // 检查app bar上是否有"home_title"
    expect(find.text("home_title".tr()), findsOneWidget);

    // 检查是否有一个GoogleMap组件
    expect(find.byType(GoogleMap), findsOneWidget);

    // 检查是否有一个设置按钮
    expect(find.widgetWithIcon(IconButton, Icons.settings), findsOneWidget);

    // 检查是否有一个刷新按钮
    expect(find.widgetWithIcon(IconButton, Icons.refresh), findsOneWidget);

    // 检查是否有一个添加event按钮
    expect(find.widgetWithIcon(IconButton, Icons.add), findsOneWidget);
  });

}
