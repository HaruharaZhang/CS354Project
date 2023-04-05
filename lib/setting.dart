import 'package:cs354_project/main.dart';
import 'package:cs354_project/selectLanguage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'GlobalVariable.dart';
import 'package:easy_localization/easy_localization.dart';

import 'changeScope.dart';
import 'changeUserName.dart';
import 'myEventList.dart';


class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isAutoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    getAutoRefresh();
  }

  void _onLogoutButtonPressed() async {
    // Show restart app dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('setting_user_logout_alert_dialog_title'.tr()),
          content: Text('setting_user_logout_alert_dialog_desc'.tr()),
          actions: [
            TextButton(
              child: Text('setting_user_logout_alert_dialog_cancel'.tr()),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
                child: Text('setting_user_logout_alert_dialog_confirm'.tr()),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Future.delayed(Duration.zero,(){
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ), (route) => route == null);
                  });
                }),
          ],
        );
      },
    );
  }

  Future<void> getAutoRefresh() async {
    bool returnValue = await GlobalVariable.getAutoRefreshEnable();
    setState(() {
      _isAutoRefreshEnabled = returnValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("setting_title").tr(),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(Icons.menu),
              title: Text('setting_my_event'.tr()),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventListPage(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.adjust_rounded),
              title: Text('setting_scope').tr(),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeScope(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('setting_auto_refresh').tr(),
              trailing: Switch(
                value: _isAutoRefreshEnabled,
                onChanged: (bool value) async {
                  await GlobalVariable.setAutoRefreshEnable(value);
                  setState(() {
                    _isAutoRefreshEnabled = value;
                    //print(value);
                  });
                },
              ),
            ),
            //语言偏好
            ListTile(
              leading: Icon(Icons.language),
              title: Text('setting_language_preference').tr(),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguageSelectionPage(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.drive_file_rename_outline),
              title: Text('setting_modify_nickname').tr(),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeUsernamePage(),
                    ));
              },
            ),
            //用户登出
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('setting_user_logout').tr(),
              onTap: () {
                _onLogoutButtonPressed();
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
