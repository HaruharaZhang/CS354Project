import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'GlobalVariable.dart';

class ChangeScope extends StatefulWidget {
  @override
  _ChangeScopeState createState() => _ChangeScopeState();
}

class _ChangeScopeState extends State<ChangeScope> {
  TextEditingController _scopeController = TextEditingController();
  String? _scope;
  String newScope = '';

  @override
  void initState() {
    super.initState();
    _getDefaultScope();
  }

  void _getDefaultScope() async {
    num scope = await GlobalVariable.getUserScope();
    setState(() {
      _scope = scope.toInt().toString();
    });
  }

  void _onConfirmButtonPressed() async {
    GlobalVariable.setUserScope(double.parse(_scopeController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('changeScope_snack_bar_desc'.tr())),
    );
    Navigator.pop(context);
  }

  Future<void> _onTextFieldChanged(String value) async {
    setState(() {
      newScope = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('changeScope_title'.tr()),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _scopeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onTextFieldChanged,
                decoration: InputDecoration(
                  labelText: 'changeScope_text_field_label_text'.tr(args: [_scope ?? '2']),
                  border: OutlineInputBorder(),
                ),
              ),
              Text('changeScope_desc'.tr()),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: newScope == "" ? null : _onConfirmButtonPressed,
                child: Text('changeScope_btn'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
