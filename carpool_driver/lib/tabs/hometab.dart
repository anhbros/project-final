import 'dart:async';

import 'package:carpool_driver/brand_colors.dart';
import 'package:carpool_driver/datamodels/directiondetails.dart';
import 'package:carpool_driver/datamodels/driver.dart';
import 'package:carpool_driver/dataprovider.dart';
import 'package:carpool_driver/globalvariabels.dart';
import 'package:carpool_driver/helpers/helpermethods.dart';
import 'package:carpool_driver/helpers/pushnotificationservice.dart';
import 'package:carpool_driver/screens/searchpage.dart';
import 'package:carpool_driver/widgets/AvailabilityButton.dart';
import 'package:carpool_driver/widgets/ConfirmSheet.dart';
import 'package:carpool_driver/widgets/ProgressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin{

  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};


  bool isVisible = false;
  double searchSheetHeight = 100;

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

    String address = await HelperMethods.findCordinateAddress(position, context);
    //in ra vi tri hien tai
    print(address);

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
          polylines: _polylines,
          markers: _Markers,
          circles: _Circles,
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

        Visibility(
          visible: isVisible,
          child: Positioned(
            top: 150,
            left: 10,
            child: GestureDetector(
              onTap: (){
                resetApp();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          )
                      )
                    ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(Icons.arrow_back , color: Colors.black87,),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSize(
            vsync: this,
            duration: new Duration(milliseconds: 150),
            curve: Curves.easeIn,
            child: Container(
              height: searchSheetHeight,
              decoration: BoxDecoration(
                  color : Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20) , topRight: Radius.circular(20)),
                  boxShadow: [BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 0.5,
                      blurRadius: 15.0,
                      offset: Offset(0.7 , 0.7)
                  )]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24 , vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {

                        var response = await  Navigator.push(context, MaterialPageRoute(
                            builder: (context)=> SearchPage()
                        ));

                        if(response == 'getDirection'){
                          //showDetailSheet();
                          await getDirection();
                          isVisible = true;
                          setState(() {
                            searchSheetHeight = 0;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 0.5,
                                blurRadius: 15.0,
                                offset: Offset(0.7 , 0.7)
                            )]

                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.search , color: Colors.blueAccent,),
                              SizedBox(width : 10 ,),
                              Text('Lịch trình chuyến đi')
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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


  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context , listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context , listen: false).destinationAddress;



    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Vui lòng chờ...',)
    );

    var thisDetails = await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);



    Navigator.pop(context);

    encodePolylineDriver = thisDetails.encodedPoints;
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);

    //print("day la vi tri tra ve ${thisDetails.encodedPoints}");
    polylineCoordinates.clear();

    if(results.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // polylineCoordinates.forEach((LatLng latLng) {
    //   print(latLng);
    // });
    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 110, 164, 236),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    // make polyline to fit into the map

    LatLngBounds bounds;

    if(pickLatLng.latitude > destinationLatLng.latitude && pickLatLng.longitude > destinationLatLng.longitude){
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    }
    else if(pickLatLng.longitude > destinationLatLng.longitude){
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude)
      );
    }
    else if(pickLatLng.latitude > destinationLatLng.latitude){
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
        northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else{
      bounds = LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'Vị trí của bạn'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: destination.placeName, snippet: 'Điểm đến'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorPink,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorPink,
    );



    setState(() {
      _Circles.add(pickupCircle);
      _Circles.add(destinationCircle);
    });
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
  resetApp(){

    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      isVisible = false;
      searchSheetHeight = 100;

    });

    encodePolylineDriver = null;
    getCurrentPosition();

  }
}
