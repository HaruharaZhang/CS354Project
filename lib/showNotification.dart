import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowNotification extends StatelessWidget {
  final String? payload;

  ShowNotification({required this.payload});

  @override
  Widget build(BuildContext context) {
    print("Inside the ShowNotification function!");
    return Scaffold(
      appBar: AppBar(
        title: Text('Target Page'),
      ),
      body: Center(
        child: Text(
          'Payload: $payload',
        ),
      ),
    );
  }
}
