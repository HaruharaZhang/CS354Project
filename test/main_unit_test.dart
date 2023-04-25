import 'package:cs354_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyHomePage', ()
  {
    late MyHomePage homePage;

    setUp(() {
      homePage = MyHomePage();
    });

    // testWidgets('login with valid credentials returns true', (
    //     WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp(home: MyHomePage()));
    //   final homePage = tester.widget<MyHomePage>(find.byType(MyHomePage));
    //   final state = tester.state<_MyHomePageState>(find.byType(MyHomePage));
    //   state.emailController.text = 'test@test.com';
    //   state.passwdController.text = 'password';
    //   expect(await state.login(), true);
    // });
  });
}
