import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  String? userLocation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    userLocation = await GetLocation().determinePosition();
    print("userLocation _--------------${userLocation}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.black,
            size: 18,
          ),
          SizedBox(
            width: 1,
          ),
          Text(userLocation ?? ""),
        ],
      ),
    );
  }
}

class GetLocation {
  late StreamSubscription<Position> streamSubscription;
  String? address;

  Future<String> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> places =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = places[0];
    address = place.subLocality;
    return address ?? "";
    // streamSubscription =
    //     Geolocator.getPositionStream().listen((Position position) {
    //   getLocality(position);
    // });
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    //return position;
  }
}
