import 'package:cs354_project/selectLocation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateNewEventPage extends StatefulWidget {
  @override
  _CreateNewEventPageState createState() => _CreateNewEventPageState();
}

class _CreateNewEventPageState extends State<CreateNewEventPage> {
  final _eventNameController = TextEditingController();
  final _eventDescController = TextEditingController();
  final _eventDateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  LatLng? _selectedLocation;
  double? locationlat;
  double? locationlng;
  final _msgController = TextEditingController();
  final _maxMsgLength = 1000;

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
    _msgController.addListener(() {
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
              decoration: InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),

            TextField(
              controller: _eventDescController,
              decoration: InputDecoration(
                labelText: 'Event Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _eventDateController,
              decoration: InputDecoration(
                labelText: 'Event Date',
                border: OutlineInputBorder(),
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

            Expanded(
              child: TextField(
                controller: _msgController,
                maxLength: _maxMsgLength,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Please input your event information',
                  counterText: '${_msgController.text.length}/$_maxMsgLength',
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                // Save the new event to the database or perform some other action
                String eventName = _eventNameController.text;
                String eventDesc = _eventDescController.text;
                String eventDate = _eventDateController.text;
                print(
                    'Created new event: $eventName on $eventDesc at $eventDate');
              },
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
