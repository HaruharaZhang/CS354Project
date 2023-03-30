import 'package:cs354_project/selectLanguage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'GlobalVariable.dart';
import 'package:easy_localization/easy_localization.dart';

import 'changeUserName.dart';


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
              leading: Icon(Icons.adjust_rounded),
              title: Text('setting_scope').tr(),
              onTap: () {
                // 范围设置的逻辑
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
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('setting_user_logout').tr(),
              onTap: () {
                // 用户登出的逻辑
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
