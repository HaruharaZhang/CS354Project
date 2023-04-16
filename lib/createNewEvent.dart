import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'Event.dart';

import 'package:cs354_project/selectLocation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:photo_manager/photo_manager.dart' as pm;
import 'package:geocoding/geocoding.dart';

//应该有一个默认的过期时间
//应该有一个提示问用户
class CreateNewEventPage extends StatefulWidget {
  @override
  _CreateNewEventPageState createState() => _CreateNewEventPageState();
}

class _CreateNewEventPageState extends State<CreateNewEventPage> {
  final _eventNameController = TextEditingController();
  final _eventDescController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventExpireDateController = TextEditingController();
  final _eventMsgController = TextEditingController();

  OutlineInputBorder _eventNameInputBorder = const OutlineInputBorder();
  OutlineInputBorder _eventDescInputBorder = const OutlineInputBorder();
  OutlineInputBorder _eventDateInputBorder = const OutlineInputBorder();
  OutlineInputBorder _eventExpireDateInputBorder = const OutlineInputBorder();
  OutlineInputBorder _eventMsgInputBorder = const OutlineInputBorder();

  OutlineInputBorder errorLineInputBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2));
  OutlineInputBorder correctLineInputBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2));

  FocusNode _eventNameFocusNode = FocusNode();
  FocusNode _eventDescFocusNode = FocusNode();
  FocusNode _eventDateFocusNode = FocusNode();
  FocusNode _eventExpireDateFocusNode = FocusNode();
  FocusNode _eventMsgFocusNode = FocusNode();

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedExpireDate = DateTime.now();
  LatLng? _selectedLocation;
  double? locationlat;
  double? locationlng;

  File? _image;
  List<pm.AssetEntity> _images = [];
  // final picker = ImagePicker.platform;

  final _maxMsgLength = 1000;
  var _selectedImage;
  //File? imageFile;
  final List<String> _dropdownOptions = [
    'Bus Problem',
    'Traffic jam',
    'Car accident',
    'Something Cool',
    'Others'
  ];
  //添加一个something else 选项
  String? _selectedValue;
  bool isBusTagSelected = false;
  String? _address;

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
      if (!_eventNameFocusNode.hasFocus) {
        if (_eventNameController.text.isEmpty) {
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
      if (!_eventDescFocusNode.hasFocus) {
        if (_eventDescController.text.isEmpty) {
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
      if (!_eventDateFocusNode.hasFocus) {
        if (_eventDateController.text.isEmpty) {
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
    _eventExpireDateFocusNode.addListener(() {
      if (!_eventExpireDateFocusNode.hasFocus) {
        if (_eventExpireDateController.text.isEmpty) {
          setState(() {
            _eventExpireDateInputBorder = errorLineInputBorder;
          });
        } else {
          if (_selectedDate.isBefore(_selectedExpireDate)) {
            setState(() {
              _eventExpireDateInputBorder = correctLineInputBorder;
            });
          } else {
            EasyLoading.showError("createNewEvent_date_logic_error".tr());
            setState(() {
              _eventExpireDateInputBorder = errorLineInputBorder;
            });
          }
        }
      }
    });
    _eventMsgFocusNode.addListener(() {
      if (!_eventMsgFocusNode.hasFocus) {
        if (_eventMsgController.text.isEmpty) {
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

  Future<void> _selectEventDate(BuildContext context) async {
    //日期选择框
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedExpireDate,
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
        _selectedExpireDate = selectedDateTime;
        _eventExpireDateController.text = _selectedExpireDate.toString();
      });
    }
  }

  Future _pickImage() async {
    final ImagePicker picker = ImagePicker();
    //final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //List<XFile>? images = await picker.pickMultiImage();
    XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 250,
      maxWidth: 250,
    );
    //final pickedFile = await picker.pickImageFromGallery();
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _fetchImages() async {
    // final permitted = await pm.PhotoManager.requestPermission();
    // if (!permitted) {
    //   // 没有权限
    //   return;
    // }
    List<pm.AssetPathEntity> albums =
        await pm.PhotoManager.getAssetPathList(onlyAll: false);
    pm.AssetPathEntity album = albums.first;
    if (album.assetCount > 0) {
      List<pm.AssetEntity> assets =
          await album.getAssetListRange(start: 0, end: album.assetCount - 1);

      setState(() {
        _images = assets;
      });
    } else {
      print("no image in the photo album");
    }
  }

  Future<bool> _createEvent() async {
    String url = '';
    if (Platform.isAndroid) {
      url = "http://10.0.2.2:8080/webapi/event_server/event/createNewEvent";
    } else {
      url = "http://127.0.0.1:8080/webapi/event_server/event/createNewEvent";
    }
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
      'userUid': FirebaseAuth.instance.currentUser?.uid,
      'exprieDate': _eventExpireDateController.text,
      'userDeviceToken': await FirebaseMessaging.instance.getToken(),
    };
    var body =
        data.entries.map((entry) => "${entry.key}=${entry.value}").join('&');
    //print("origion data is $body");
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    //print(body);
    //print(response.body);
    if (response.statusCode == 200) {
      //print('Data sent successfully');
      String tagUrl = '';
      if (Platform.isAndroid) {
        tagUrl =
            "http://10.0.2.2:8080/webapi/event_server/event/tag/createNewTag";
      } else {
        tagUrl =
            "http://127.0.0.1:8080/webapi/event_server/event/tag/createNewTag";
      }
      Map tagData = {
        'event_id': response.body,
        'event_tag': _selectedValue,
      };
      //print(_selectedValue);
      var tagBody = tagData.entries
          .map((entry) => "${entry.key}=${entry.value}")
          .join('&');
      //print(tagBody);
      final tagResponse =
          await http.post(Uri.parse(tagUrl), headers: headers, body: tagBody);
      if (tagResponse.statusCode == 200) {
        return true; //成功
      }
      return false; //提交数据失败
    } else {
      print('Error sending data with error response code: ' +
          response.statusCode.toString());
      return false;
    }
  }

  bool checkUserInput() {
    if (_eventNameController.text.isEmpty ||
        _eventDescController.text.isEmpty ||
        _eventDateController.text.isEmpty ||
        _eventExpireDateController.text.isEmpty ||
        _selectedLocation == null ||
        _eventMsgController.text.isEmpty ||
        _selectedValue == null) {
      return false;
    }
    if (_selectedDate.isBefore(_selectedExpireDate)) {
      return true;
    }
    return false;
  }

  //将经纬度转换为地址信息
  Future<void> getAddress(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0]; // 获取第一个地址信息
    String address;
    //如果找不到地址信息的话，使用特定字符串替代
    if (place.street == "") {
      address =
          "${"createNewEvent_new_event_unknown_street".tr()}, ${place.subLocality}, ${place.locality}, ${place.country}";
    } else {
      address =
          "${place.street} , ${place.subLocality}, ${place.locality}, ${place.country}";
    }
    setState(() {
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('createNewEvent_title'.tr()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('createNewEvent_discard_box'.tr()),
                content: Text('createNewEvent_discard_desc'.tr()),
                actions: [
                  TextButton(
                    child: Text('createNewEvent_discard_cancel'.tr()),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text('createNewEvent_discard_confirm'.tr()),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.max,
            children: [
              TextField(
                controller: _eventNameController,
                focusNode: _eventNameFocusNode,
                decoration: InputDecoration(
                  labelText: 'createNewEvent_new_event'.tr(),
                  enabledBorder: _eventNameInputBorder,
                  //border: _eventNameInputBorder,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _eventDescController,
                focusNode: _eventDescFocusNode,
                decoration: InputDecoration(
                  labelText: 'createNewEvent_new_event_desc'.tr(),
                  enabledBorder: _eventDescInputBorder,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                //选择时间
                controller: _eventDateController,
                focusNode: _eventDateFocusNode,
                decoration: InputDecoration(
                  labelText: 'createNewEvent_new_event_start_date'.tr(),
                  enabledBorder: _eventDateInputBorder,
                ),
                onTap: () {
                  _selectDate(context);
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                //选择过期时间
                controller: _eventExpireDateController,
                focusNode: _eventExpireDateFocusNode,
                decoration: InputDecoration(
                  labelText: 'createNewEvent_new_event_expire_date'.tr(),
                  enabledBorder: _eventExpireDateInputBorder,
                ),
                onTap: () {
                  _selectEventDate(context);
                },
              ),
              SizedBox(height: 16.0),
              if (_selectedLocation != null)
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text('createNewEvent_new_event_selected_location'
                      .tr(args: [_address ?? ""])),
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
                    getAddress(locationlat!, locationlng!);
                  });
                  // 输出选择的位置
                  if (result != null) {
                    //print('Selected location: $result');
                  }
                },
                child: Text(_selectedLocation == null
                    ? 'createNewEvent_new_event_select_location'.tr()
                    : 'createNewEvent_new_event_change_location'.tr()),
              ),
              SizedBox(height: 16.0),
              Flexible(
                child: TextField(
                  controller: _eventMsgController,
                  focusNode: _eventMsgFocusNode,
                  maxLength: _maxMsgLength,
                  minLines: 1,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText:
                        'createNewEvent_new_event_information_hit_text'.tr(),
                    enabledBorder: _eventMsgInputBorder,
                    counterText:
                        '${_eventMsgController.text.length}/$_maxMsgLength',
                  ),
                ),
              ),
              //如果选择了图片，就将其显示出来
              //if (_selectedImage != null) Image.file(_selectedImage),
              if (_selectedImage != null)
                GridView.builder(
                  itemCount: _images.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return ImageThumbnail(asset: _images[index]);
                  },
                ),

              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "createNewEvent_new_event_tag".tr(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // CheckboxListTile(
                    //   title: const Text('Bus problem'),
                    //   value: isBusTagSelected,
                    //   onChanged: (bool? value) {
                    //     setState(() {
                    //       isBusTagSelected = value!;
                    //     });
                    //   },
                    //   secondary: const Icon(Icons.bus_alert),),
                    DropdownButton<String>(
                        value: _selectedValue,
                        items: _dropdownOptions
                            .map<DropdownMenuItem<String>>((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                            //print(_selectedValue);
                          });
                        }),
                  ],
                ),
              ),

              //因为选择图片总是会报PlatformException(invalid_source, Invalid image source., null, null)
              //错误，并且尝试半天仍然无法修复
              //故将此功能取消
              ElevatedButton(
                onPressed: () => _fetchImages(),
                //onPressed: () => _pickImage(),
                //onPressed: () => null,
                child: Text('createNewEvent_new_event_add_picture_btn'.tr()),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (checkUserInput()) {
                    EasyLoading.show(status:
                        "createNewEvent_new_event_creating_event".tr());
                    if (await _createEvent()) {
                      EasyLoading.dismiss();
                      EasyLoading.showSuccess(
                          "createNewEvent_new_event_creating_event_done".tr());
                      Navigator.pop(
                        context,
                      );
                    }
                  } else {
                    EasyLoading.dismiss();
                    EasyLoading.showError(
                        "createNewEvent_new_event_create_event_error".tr());
                  }
                },
                child: Text('createNewEvent_new_event_btn'.tr()),
              ),
            ],
          ),
        ),
    );
  }
}

class ImageThumbnail extends StatefulWidget {
  final pm.AssetEntity asset;

  const ImageThumbnail({Key? key, required this.asset}) : super(key: key);

  @override
  _ImageThumbnailState createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<ImageThumbnail> {
  late Future<File?> _fileFuture;

  @override
  void initState() {
    super.initState();
    _fileFuture = widget.asset.file;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _fileFuture,
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.file(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
