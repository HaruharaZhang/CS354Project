import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'Event.dart';

import 'package:cs354_project/selectLocation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CreateNewEventPage extends StatefulWidget {
  @override
  _CreateNewEventPageState createState() => _CreateNewEventPageState();
}

class _CreateNewEventPageState extends State<CreateNewEventPage> {
  final _eventNameController = TextEditingController();
  final _eventDescController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventMsgController = TextEditingController();

  OutlineInputBorder _eventNameInputBorder = const OutlineInputBorder();
  OutlineInputBorder _eventDescInputBorder = const OutlineInputBorder();
  OutlineInputBorder _eventDateInputBorder = const OutlineInputBorder();
  OutlineInputBorder _eventMsgInputBorder = const OutlineInputBorder();

  OutlineInputBorder errorLineInputBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2));
  OutlineInputBorder correctLineInputBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2));

  FocusNode _eventNameFocusNode = FocusNode();
  FocusNode _eventDescFocusNode = FocusNode();
  FocusNode _eventDateFocusNode = FocusNode();
  FocusNode _eventMsgFocusNode = FocusNode();

  DateTime _selectedDate = DateTime.now();
  LatLng? _selectedLocation;
  double? locationlat;
  double? locationlng;

  File? _image;
  // final picker = ImagePicker.platform;

  final _maxMsgLength = 1000;
  var _selectedImage;
  //File? imageFile;

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescController.dispose();
    _eventDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _eventNameInputBorder = OutlineInputBorder();

    _eventNameFocusNode.addListener(() {
      if(!_eventNameFocusNode.hasFocus){
        if(_eventNameController.text.isEmpty){
          setState(() {
            _eventNameInputBorder = errorLineInputBorder;
          });
        } else {
          setState(() {
            _eventNameInputBorder = correctLineInputBorder;
          });
        }
      }
    });
    _eventDescFocusNode.addListener(() {
      if(!_eventDescFocusNode.hasFocus){
        if(_eventDescController.text.isEmpty){
          setState(() {
            _eventDescInputBorder = errorLineInputBorder;
          });
        } else {
          setState(() {
            _eventDescInputBorder = correctLineInputBorder;
          });
        }
      }
    });
    _eventDateFocusNode.addListener(() {
      if(!_eventDateFocusNode.hasFocus){
        if(_eventDateController.text.isEmpty){
          setState(() {
            _eventDateInputBorder = errorLineInputBorder;
          });
        } else {
          setState(() {
            _eventDateInputBorder = correctLineInputBorder;
          });
        }
      }
    });
    _eventMsgFocusNode.addListener(() {
      if(!_eventMsgFocusNode.hasFocus){
        if(_eventMsgController.text.isEmpty){
          setState(() {
            _eventMsgInputBorder = errorLineInputBorder;
          });
        } else {
          setState(() {
            _eventMsgInputBorder = correctLineInputBorder;
          });
        }
      }
    });


    _eventMsgController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    //日期选择框
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1200),
      lastDate: DateTime(3000),
      //选取日期的间隔
    );
    //时间选择框
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (date != null && time != null) {
      final selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      setState(() {
        _selectedDate = selectedDateTime;
        _eventDateController.text = _selectedDate.toString();
      });
    }
  }

  Future _pickImage() async {
    final ImagePicker picker = ImagePicker();
    //final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //List<XFile>? images = await picker.pickMultiImage();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery,
      maxHeight: 250,
      maxWidth: 250,);
    //final pickedFile = await picker.pickImageFromGallery();
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<bool> _createEvent() async {
    String url =
        "http://127.0.0.1:8080/webapi/event_server/event/createNewEvent";
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    //final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    Map data = {
      'eventName': _eventNameController.text,
      'eventAuth': FirebaseAuth.instance.currentUser?.displayName,
      'eventTime': _eventDateController.text,
      'eventDesc': _eventDescController.text,
      'eventLat': locationlat,
      'eventLng': locationlng,
      'eventMsg': _eventMsgController.text,
    };
    var body = data.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .join('&');
    //print("origion data is $body");
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      //print('Data sent successfully');
      return true;
    } else {
      print('Error sending data with error response code: ' +
          response.statusCode.toString());
      return false;
    }
  }

  bool checkUserInput(){
    if(_eventNameController.text.isEmpty
    || _eventDescController.text.isEmpty
    || _eventDateController.text.isEmpty
    || _selectedLocation == null
    || _eventMsgController.text.isEmpty){
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Event'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Discard Changes?'),
                content: Text(
                    'Are you sure you want to discard all your changes and go back?'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text('Discard'),
                    onPressed: () {
                      //这里一个是返回提示框，一个是返回上级菜单
                      //所以才会需要两个pop
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _eventNameController,
              focusNode: _eventNameFocusNode,
              decoration: InputDecoration(
                labelText: 'Event Name',
                enabledBorder: _eventNameInputBorder,
                //border: _eventNameInputBorder,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _eventDescController,
              focusNode: _eventDescFocusNode,
              decoration: InputDecoration(
                labelText: 'Event Description',
                enabledBorder: _eventDescInputBorder,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _eventDateController,
              focusNode: _eventDateFocusNode,
              decoration: InputDecoration(
                labelText: 'Event Date',
                enabledBorder: _eventDateInputBorder,
              ),
              onTap: () {
                _selectDate(context);
              },
            ),
            SizedBox(height: 16.0),
            if (_selectedLocation != null)
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text('Selected location: $locationlat + $locationlng'),
              ),
            ElevatedButton(
              onPressed: () async {
                // 启动 Google Maps
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SelectLocationPage(),
                  ),
                );
                //根据获取到的结果更新页面
                //这里其实是更新了一个值，但是处于setState()中的变量会自动更新页面
                setState(() {
                  _selectedLocation = result;
                  locationlat = _selectedLocation!.latitude;
                  locationlng = _selectedLocation!.longitude;
                });
                // 输出选择的位置
                if (result != null) {
                  print('Selected location: $result');
                }
              },
              child: Text(_selectedLocation == null
                  ? 'Select location'
                  : 'Change location'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _eventMsgController,
                focusNode: _eventMsgFocusNode,
                maxLength: _maxMsgLength,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Please input your event information',
                  enabledBorder: _eventMsgInputBorder,
                  counterText: '${_eventMsgController.text.length}/$_maxMsgLength',
                ),
              ),
            ),
            //如果选择了图片，就将其显示出来
            if (_selectedImage != null) Image.file(_selectedImage),
            //因为选择图片总是会报PlatformException(invalid_source, Invalid image source., null, null)
            //错误，并且尝试半天仍然无法修复
            //故将此功能取消
            // ElevatedButton(
            //
            //   onPressed: () => _pickImage(),
            //   //onPressed: () => null,
            //   child: Text('Add picture'),
            // ),
            ElevatedButton(
              onPressed: () async {
                if(checkUserInput()) {
                  EasyLoading.showInfo("Creating event...");
                  if(await _createEvent()){
                    EasyLoading.showSuccess("Done! event created");
                    Navigator.pop(context);
                  }
                } else {
                  EasyLoading.showError("Cannot create event! please check your input");
                }
              },
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
