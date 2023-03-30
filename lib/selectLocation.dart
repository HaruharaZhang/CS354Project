import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationPage extends StatefulWidget {
  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  late LatLng _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('selectLocation_title'.tr()),
      ),
      body: GoogleMap(

        initialCameraPosition: CameraPosition(
          target: LatLng(51.6156036, -3.9811275),
          zoom: 14.0,

        ),
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        compassEnabled: true,
        onTap: (latLng) {
          setState(() {
            _selectedLocation = latLng;
          });
          Navigator.of(context).pop(_selectedLocation);
        },
      ),
    );
  }
}
