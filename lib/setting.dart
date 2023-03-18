import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'GlobalVariable.dart';

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
        title: Text('Options'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(Icons.adjust_rounded),
              title: Text('范围设置'),
              onTap: () {
                // 范围设置的逻辑
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('自动刷新'),
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
            ListTile(
              leading: Icon(Icons.language),
              title: Text('语言偏好'),
              onTap: () {
                // 语言偏好设置的逻辑
              },
            ),
            ListTile(
              leading: Icon(Icons.drive_file_rename_outline),
              title: Text('修改昵称'),
              onTap: () {
                // 修改昵称的逻辑
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('用户登出'),
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
