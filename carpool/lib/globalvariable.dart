import 'package:carpool/datamodels/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String serverKey = 'AAAAm58oDQ8:APA91bHlpGyd6VyWPLRomcADDmMiBZkyCk_Fe_y0Ux_QNCXVnW80DK3Supx1tJQgNPUwK5YSRWN-7HKbF3UnVjP-w9ykM617W86FKTEzHeYL-CHCkqn8XNfHv4JRLJ9Tj2NthYYDMQZa';
String mapKey = 'AIzaSyCvsxvlCkhA_X4L6BdDA1RO1X6ng-M8Nts';
String geoCodeKey = 'AIzaSyDDyFy-V-_kDmxyu7fm1-4YkbSfo4LHRlo';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(21.0347636, 105.7786071),
  zoom: 14.4746,
);

FirebaseUser currentFirebaseUser;
User currentUserInfo;