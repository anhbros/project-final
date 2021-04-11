import 'package:carpool/datamodels/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String serverKey = 'key=AAAAm58oDQ8:APA91bFax86zwZzDsbQbcr-P7jIabxdsvleuaFssHaqGiJ8bDgsbapNY7HjzKsQAmp-hL7j5k7-_uIG1td5GOXYgVZvfMvJN1CHG8ps4gjzmkfu3NHLVoiDDVqvsR7SJLDLVQu6X8i1T';
String mapKey = 'AIzaSyCvsxvlCkhA_X4L6BdDA1RO1X6ng-M8Nts';
String geoCodeKey = 'AIzaSyDDyFy-V-_kDmxyu7fm1-4YkbSfo4LHRlo';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(21.0347636, 105.7786071),
  zoom: 14.4746,
);

FirebaseUser currentFirebaseUser;
User currentUserInfo;