import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:carpool_driver/datamodels/tripdetails.dart';
import 'package:carpool_driver/globalvariabels.dart';
import 'package:carpool_driver/widgets/NotificationDialog.dart';
import 'package:carpool_driver/widgets/ProgressDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
//import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:google_maps_utils/google_maps_utils.dart';
class PushNotificationService{

  final FirebaseMessaging fcm = FirebaseMessaging();


  Future initialize(context) async {

    if(Platform.isIOS){
      fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    fcm.configure(

      onMessage: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideID(message), context);
      },
      onLaunch: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message), context);

      },
      onResume: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message), context);

      },

    );

  }

  Future<String> getToken() async{

    String token = await fcm.getToken();
    print('token: $token');

    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');

  }

  String getRideID(Map<String, dynamic> message){

    String rideID = '';

    if(Platform.isAndroid){
      rideID = message['data']['ride_id'];
    }
    else{
     rideID = message['ride_id'];
      print('ride_id: $rideID');
    }

    return rideID;
  }

  void fetchRideInfo(String rideID, context){

    //show please wait dialog
    // showDialog(
    //   barrierDismissible: false,
    //   context: context,
    //   builder: (BuildContext context) => ProgressDialog(status: 'Đang lấy dữ liệu',),
    // );

    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideID');
    rideRef.once().then((DataSnapshot snapshot){

      //Navigator.pop(context);

      if(snapshot.value != null){

        // assetsAudioPlayer.open(
        //   Audio('sounds/alert.mp3'),
        // );
        // assetsAudioPlayer.play();

        double pickupLat = double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng = double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat = double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng = double.parse(snapshot.value['destination']['longitude'].toString());
        String destinationAddress = snapshot.value['destination_address'];
        String paymentMethod = snapshot.value['payment_method'];
        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];

        TripDetails tripDetails = TripDetails();

        tripDetails.rideID = rideID;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = gg.LatLng(pickupLat, pickupLng);
        tripDetails.destination = gg.LatLng(destinationLat, destinationLng);
        tripDetails.paymentMethod = paymentMethod;
        tripDetails.riderName = riderName;
        tripDetails.riderPhone = riderPhone;

        bool isMappingRequest;

        if(encodePolylineDriver == null){
          isMappingRequest = false;
          print("this is my 1 ${isMappingRequest}");
        }else{
          Point pickupPoint = Point(pickupLat, pickupLng);
          Point destinationPoint = Point(destinationLat, destinationLng);
          //print("this my endcode ${encodePolylineDriver}");
          List<Point> path = PolyUtils.decode(encodePolylineDriver);
          // path.forEach((Point point) {
          //   print(point);
          // });
          isMappingRequest = PolyUtils.isLocationOnEdgeTolerance(destinationPoint, path, false , 200);
          print("this is my 2 ${isMappingRequest}");
        }
        print("this is my 3 ${isMappingRequest}");

        if(isMappingRequest){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialog(tripDetails: tripDetails,),
          );
        }


      }

    });
  }

}