import 'package:cs354_project/home.dart';
import 'package:cs354_project/reguist.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs354_project/main.dart';

void main() {
  testWidgets('Test MyHomePage Widget', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    final loginButton = find.widgetWithText(ElevatedButton, 'main_login_btn'.tr());
    final registerButton = find.widgetWithText(ElevatedButton, 'main_register_btn'.tr());

    // 检查页面上是否有登录按钮和注册按钮
    expect(loginButton, findsOneWidget);
    expect(registerButton, findsOneWidget);

    // 在email和passwd输入框中分别输入无效的值，应该显示相应错误信息
    final emailTextField = find.byType(TextField).first;
    final passwordTextField = find.byType(TextField).last;
    await tester.enterText(emailTextField, 'not_a_valid_email');
    await tester.enterText(passwordTextField, 'short');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('main_invalid_email_format'.tr()), findsOneWidget);
    expect(find.text('main_wrong_passwd'.tr()), findsOneWidget);

    // 在email和passwd输入框中分别输入有效的值，应该成功登录并跳转到MapPage
    await tester.enterText(emailTextField, 'test@test.com');
    await tester.enterText(passwordTextField, '123456');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('main_welcome_back'.tr(args: ['test'])), findsOneWidget);
    expect(find.byType(MapPage), findsOneWidget);
  });

  testWidgets('Test email and password input', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MyHomePage()));
    await tester.pumpAndSettle();

    // 输入正确的邮箱和密码，查看输入框状态是否正常
    final emailField = find.byKey(ValueKey('email-field'));
    final passwdField = find.byKey(ValueKey('passwd-field'));
    final loginBtn = find.byKey(ValueKey('login-btn'));

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwdField, '123456');
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    // 检查输入框的状态是否正确
    // expect(tester.widget<TextField>(emailField).decoration?.enabledBorder,
    //     equals(MyHomePage().emailInputBorder));
    // expect(tester.widget<TextField>(passwdField).decoration?.enabledBorder,
    //     equals(MyHomePage().outlineInputBorder));

    // 输入无效的邮箱地址，查看输入框状态是否正常
    await tester.enterText(emailField, 'invalid-email');
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    // 检查输入框的状态是否正确
    // expect(tester.widget<TextField>(emailField).decoration?.enabledBorder,
    //     equals(MyHomePage().errorLineInputBorder));
    expect(tester.widget<TextField>(emailField).decoration?.counterText,
        equals('main_invalid_email_format'.tr()));
  });
  testWidgets('Test login feedback', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MyHomePage()));
    await tester.pumpAndSettle();

    final emailField = find.byKey(ValueKey('email-field'));
    final passwdField = find.byKey(ValueKey('passwd-field'));
    final loginBtn = find.byKey(ValueKey('login-btn'));

    // 输入正确的邮箱和密码，进行登录，检查反馈是否正常
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwdField, '123456');
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.text('main_trying_to_login'.tr()), findsOneWidget);

    // 模拟登录失败，检查反馈是否正常
    // MyHomePage().login = () async {
    //   return false;
    // };
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.text('main_trying_to_login'.tr()), findsOneWidget);
    expect(find.text('Fail to login!'), findsOneWidget);

    // 模拟登录成功，检查反馈是否正常
    // MyHomePage().login = () async {
    //   return true;
    // };
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.text('main_trying_to_login'.tr()), findsOneWidget);
  });
  testWidgets('Test login with valid email and password', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MyHomePage()));

    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;
    final loginButton = find.widgetWithText(ElevatedButton, 'main_login_btn'.tr());

    // 输入正确的邮箱和密码
    await tester.enterText(emailField, 'example@example.com');
    await tester.enterText(passwordField, '123456');

    // 点击登录按钮
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 检查是否成功跳转到地图页面
    expect(find.byType(MapPage), findsOneWidget);
  });
  testWidgets('Test login with invalid email or password', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MyHomePage()));

    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;
    final loginButton = find.widgetWithText(ElevatedButton, 'main_login_btn'.tr());

    // 输入错误的邮箱和密码
    await tester.enterText(emailField, 'example@example.com');
    await tester.enterText(passwordField, 'wrongpassword');

    // 点击登录按钮
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 检查是否出现错误提示
    expect(find.text('main_wrong_passwd'.tr()), findsOneWidget);
  });
  testWidgets('Test navigate to register page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MyHomePage()));

    final registerButton = find.widgetWithText(ElevatedButton, 'main_register_btn'.tr());

    // 点击注册按钮
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // 检查是否成功跳转到注册页面
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('Test navigate to login page when not logged in', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MapPage()));

    // 检查是否成功跳转到登录页面
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  // testWidgets('Test navigate to map page when logged in', (WidgetTester tester) async {
  //   // 模拟已登录状态
  //   FirebaseAuth.instance.currentUser = User(uid: 'uid', displayName: 'Test User');
  //
  //   await tester.pumpWidget(MaterialApp(home: MapPage()));
  //
  //   // 检查是否成功跳转到地图页面
  //   expect(find.byType(MapPage), findsOneWidget);
  // });
}
