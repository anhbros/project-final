import 'dart:convert';
import 'dart:math';

import 'package:carpool/datamodels/Address.dart';
import 'package:carpool/datamodels/DirectionDetails.dart';
import 'package:carpool/datamodels/User.dart';
import 'package:carpool/dataprovider/AppData.dart';
import 'package:carpool/globalvariable.dart';
import 'package:carpool/support/RequestHelper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carpool/globalvariable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class HelperMethods {

  static void getCurrentUserInfo() async{

    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    String userId = currentFirebaseUser.uid;

    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users/$userId');
    userRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){
        currentUserInfo = User.fromSnapshot(snapshot);
        print('Rider : ${currentUserInfo.fullName}');
      }

    });
  }

  //get location by coordinate
  static Future<String> findCordinateAddress(Position position , context) async{
    String placeAddress = '';
    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
      return placeAddress;
    }

    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$geoCodeKey';

    var response = await RequestHelper.getRequest(url);

    if(response != 'failed'){
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address();

      pickupAddress.longitude = position.longitude;
      pickupAddress.latitude = position.latitude;
      pickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickupAddress(pickupAddress);

    }

    return placeAddress;
  }

  //get direction
  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async {

    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    if(response == 'failed'){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }
  static int estimateFares (DirectionDetails details){
    // per km = 9000 vnd,
    // per minute = 300 vnd,
    // base fare = 20000 vnd,

    double baseFare = 20000;
    double distanceFare = (details.distanceValue/1000) * 9000;
    double timeFare = (details.durationValue / 60) * 300;

    double totalFare = baseFare + distanceFare + timeFare;

    return totalFare.truncate();
  }
  static double generateRandomNumber(int max){

    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);

    return randInt.toDouble();
  }

  static sendNotification(String token, context, String ride_id) async {

    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };

    Map notificationMap = {
      'title': 'YÊU CẦU CHUYẾN XE MỚI',
      'body': 'Destination, ${destination.placeName}'
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_id' : ride_id,
    };

    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token
    };

    var response = await http.post(
        'https://fcm.googleapis.com/fcm/send',
        headers: headerMap,
        body: jsonEncode(bodyMap)
    );

    print(response.body);

  }
}