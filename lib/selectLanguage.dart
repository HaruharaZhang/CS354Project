import 'dart:io';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import 'GlobalVariable.dart';

class LanguageSelectionPage extends StatefulWidget {
  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  var _languages = ['English', '简体中文'];

  var _selectedLanguage;

  Future<void> _onLanguageSelected(dynamic language) async {
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _onConfirmButtonPressed() async {
    // Show restart app dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('selectLanguage_alert_dialog_restart_app_title'.tr()),
          content: Text('selectLanguage_alert_dialog_restart_app_desc'.tr()),
          actions: [
            TextButton(
              child: Text('selectLanguage_alert_dialog_restart_app_cancel'.tr()),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
                child: Text('selectLanguage_alert_dialog_restart_app_confirm'.tr()),
                onPressed: () async {
                  GlobalVariable.setUserLanguage(
                      _getLocaleFromLanguageCode(_selectedLanguage));
                  //延迟0.5秒让app保存数据
                  Future.delayed(Duration(milliseconds: 500), () {
                    SystemNavigator.pop();
                    exit(0);
                  });
                }),
          ],
        );
      },
    );
  }

  String _getLocaleFromLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en';
      case '简体中文':
        return 'zh';
      default:
        return 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('selectLanguage_title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('selectLanguage_desc'.tr()),
            SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: 'selectLanguage_label_text'.tr(),
                border: OutlineInputBorder(),
              ),
              items: _languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: _onLanguageSelected,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('selectLanguage_confirm_btn'.tr()),
              onPressed:
                  _selectedLanguage == null ? null : _onConfirmButtonPressed,
            ),
          ],
        ),
      ),
    );
  }
}
