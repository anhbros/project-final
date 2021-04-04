
import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:carpool_driver/datamodels/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

FirebaseUser currentFirebaseUser;

String mapKey = 'AIzaSyCvsxvlCkhA_X4L6BdDA1RO1X6ng-M8Nts';
String geoCodeKey = 'AIzaSyDDyFy-V-_kDmxyu7fm1-4YkbSfo4LHRlo';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(21.0347636, 105.7786071),
  zoom: 14.4746,
);


StreamSubscription<Position> homeTabPositionStream;

StreamSubscription<Position> ridePositionStream;

final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

DatabaseReference rideRef;

Driver currentDriverInfo;

