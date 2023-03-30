import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ChangeUsernamePage extends StatefulWidget {
  @override
  _ChangeUsernamePageState createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';

  void _onConfirmButtonPressed() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('changeUserName_alert_dialog_title'.tr()),
          content: Text('changeUserName_alert_dialog_desc'.tr(args: [_username])),
          actions: [
            TextButton(
              child: Text('changeUserName_alert_dialog_cancel'.tr()),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
                child: Text('changeUserName_alert_dialog_confirm'.tr()),
                onPressed: () async {
                  EasyLoading.show(status: 'Loading...');
                  FirebaseAuth.instance.currentUser!.updateDisplayName(_username);
                  EasyLoading.showSuccess('Update Success!');
                  Navigator.pop(context);
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('changeUserName_title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('changeUserName_desc'.tr(args: [FirebaseAuth.instance.currentUser!.displayName ?? "Anonymous"])),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'changeUserName_label_hit_text'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'changeUserName_error_msg'.tr();
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _username == '' ? null : _onConfirmButtonPressed,
                child: Text('changeUserName_confirm_btn'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
