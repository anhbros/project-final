import 'dart:async';

import 'package:carpool_driver/brand_colors.dart';
import 'package:carpool_driver/datamodels/driver.dart';
import 'package:carpool_driver/globalvariabels.dart';
import 'package:carpool_driver/helpers/helpermethods.dart';
import 'package:carpool_driver/helpers/pushnotificationservice.dart';
import 'package:carpool_driver/widgets/AvailabilityButton.dart';
import 'package:carpool_driver/widgets/ConfirmSheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  DatabaseReference tripRequestRef;

  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  String availabilityTitle = 'TRỰC TUYẾN';
  Color availabilityColor = BrandColors.colorOrange;

  bool isAvailable = false;


  void getCurrentPosition() async {

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));

  }

  void getCurrentDriverInfo () async {

    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}');
    driverRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        print(currentDriverInfo.fullName);
      }

    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();

    HelperMethods.getHistoryInfo(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
            mapController = controller;

            getCurrentPosition();
          },
        ),
        Container(
          height: 135,
          width: double.infinity,
          color: BrandColors.colorPrimary,
        ),

        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: (){


                showModalBottomSheet(
                  isDismissible: false,
                    context: context,
                    builder: (BuildContext context) => ConfirmSheet(
                      title: (!isAvailable) ? 'TRỰC TUYẾN' : 'NGOẠI TUYẾN',
                      subtitle: (!isAvailable) ? 'Bạn sẽ nhập được thông báo yêu cầu chuyến xe gần đây': 'Bạn sẽ không nhận được thông báo yêu cầu chuyến xe',

                      onPressed: (){

                        if(!isAvailable){
                          GoOnline();
                          getLocationUpdates();
                          Navigator.pop(context);

                          setState(() {
                            availabilityColor = BrandColors.colorGreen;
                            availabilityTitle = 'NGOẠI TUYẾN';
                            isAvailable = true;
                          });

                        }
                        else{

                          GoOffline();
                          Navigator.pop(context);
                          setState(() {
                            availabilityColor = BrandColors.colorOrange;
                            availabilityTitle = 'TRỰC TUYẾN';
                            isAvailable = false;
                          });
                        }

                      },
                    ),
                );

                },
              ),
            ],
          ),
        )

      ],
    );
  }

  void GoOnline(){
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newtrip');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {

    });

  }

  void GoOffline (){

    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;

  }

  void getLocationUpdates(){

    homeTabPositionStream = geoLocator.getPositionStream(locationOptions).listen((Position position) {
      currentPosition = position;

      if(isAvailable){
        Geofire.setLocation(currentFirebaseUser.uid, position.latitude, position.longitude);
      }

      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));

    });

  }
}