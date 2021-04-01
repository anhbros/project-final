import 'dart:async';
import 'dart:io';

import 'package:carpool/brand_colors.dart';
import 'package:carpool/datamodels/DirectionDetails.dart';
import 'package:carpool/dataprovider/AppData.dart';
import 'package:carpool/screens/searchpage.dart';
import 'package:carpool/support/HelperMethods.dart';
import 'package:carpool/widgets/BrandDivider.dart';
import 'package:carpool/widgets/ProgressDialog.dart';
import 'package:carpool/widgets/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:carpool/globalvariable.dart';


class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  double searchSheetHeight = 280;
  double rideDetailsSheetHeight = 0; // (Platform.isAndroid) ? 235 : 260
  double requestingSheetHeight = 0; // (Platform.isAndroid) ? 195 : 220
  double tripSheetHeight = 0; // (Platform.isAndroid) ? 275 : 300

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  var geoLocator = Geolocator();
  Position currentPosition;

  DirectionDetails tripDirectionDetails;
  bool drawerCanOpen = true;


  //get current location
  void setupPositionLocator() async{
    Position position = await geoLocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));


    String address = await HelperMethods.findCordinateAddress(position, context);
    print(address);
  }

  //show detail box under map
  void showDetailSheet () async {
    await getDirection();

    setState(() {
      searchSheetHeight = 0;
      mapBottomPadding = 240;
      rideDetailsSheetHeight = 235;
      drawerCanOpen = false;
    });
  }


  double mapBottomPadding = 0;




  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(

          child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[

              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                      color: Colors.white
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset('images/user_icon.png', height: 60, width: 60,),
                      SizedBox(width: 15,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Anh Nguyen', style: TextStyle(fontSize: 20, fontFamily: 'Lexend-Bold'),),
                          SizedBox(height: 5,),
                          Text('View Profile'),
                        ],
                      )

                    ],
                  ),
                ),
              ),
              BrandDivider(),

              SizedBox(height: 10,),

              // ListTile(
              //   leading: Icon(OMIcons.cardGiftcard),
              //   title: Text('Quà tặng', style: TextStyle(fontSize: 16,),),
              // ),

              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text('Thanh toán', style: TextStyle(fontSize: 16,),),
              ),

              ListTile(
                leading: Icon(OMIcons.history),
                title: Text('Lịch sử', style: TextStyle(fontSize: 16,),),
              ),

              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text('Hỗ trợ', style: TextStyle(fontSize: 16,),),
              ),

              ListTile(
                leading: Icon(OMIcons.info),
                title: Text('About', style: TextStyle(fontSize: 16,),),
              ),

            ],
          ),
        ),
      ),
        body: Stack(
          children: <Widget>[
            GoogleMap(initialCameraPosition: googlePlex , mapType: MapType.normal,
              padding: EdgeInsets.only(bottom: mapBottomPadding),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              polylines: _polylines,
              markers: _Markers,
              circles: _Circles,
              onMapCreated: (GoogleMapController controller){
                _controller.complete(controller);
                mapController = controller;

                setState(() {
                  mapBottomPadding = 280;
                });

                setupPositionLocator();
              },
            ) ,
          //menu button
            Positioned(
              top: 44,
              left: 20,
              child: GestureDetector(
                onTap: (){
                  if(drawerCanOpen){
                      scaffoldKey.currentState.openDrawer();
                  }
                  else{
                    resetApp();
                  }
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
                    child: Icon((drawerCanOpen) ? Icons.menu : Icons.arrow_back, color: Colors.black87,),
                  ),
                ),
              ),
            ),

            //search box
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
                        SizedBox(height: 5,),
                        Text('Thật tuyệt khi bạn trở lại', style: TextStyle(fontSize: 10),),
                        SizedBox(height: 5,),
                        Text('Bạn muốn đi đâu nhỉ?', style: TextStyle(fontSize: 18 , fontFamily: 'Lexend-Bold'),),

                        SizedBox(height: 20,) ,

                        GestureDetector(
                          onTap: () async {

                            var response = await  Navigator.push(context, MaterialPageRoute(
                                builder: (context)=> SearchPage()
                            ));

                            if(response == 'getDirection'){
                              showDetailSheet();
                              //await getDirection();
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
                                  Text('Điểm đến ?')
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 22,),
                        Row(
                          children: <Widget>[
                            Icon(OMIcons.home, color: BrandColors.colorDimText,),
                            SizedBox(width: 12,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Nhà riêng'),
                                SizedBox(height: 3,),
                                Text('Địa chỉ khu dân cư',
                                  style: TextStyle(fontSize: 11, color: BrandColors.colorDimText,),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10,),

                        BrandDivider() ,

                        SizedBox(height: 16,),

                        Row(
                          children: <Widget>[
                            Icon(OMIcons.workOutline, color: BrandColors.colorDimText,),
                            SizedBox(width: 12,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Nơi làm việc'),
                                SizedBox(height: 3,),
                                Text('Địa chỉ văn phòng',
                                  style: TextStyle(fontSize: 11, color: BrandColors.colorDimText,),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //ride detail box
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0, // soften the shadow
                        spreadRadius: 0.5, //extend the shadow
                        offset: Offset(
                          0.7, // Move to right 10  horizontally
                          0.7, // Move to bottom 10 Vertically
                        ),
                      )
                    ],

                  ),
                  height: rideDetailsSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: <Widget>[

                        Container(
                          width: double.infinity,
                          color: BrandColors.colorAccent1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                Image.asset('images/taxi_img.png', height: 70, width: 70,),
                                SizedBox(width: 16,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Taxi', style: TextStyle(fontSize: 18, fontFamily: 'Lexend-Bold'),),
                                    //Text((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : '', style: TextStyle(fontSize: 16, color: BrandColors.colorTextLight),)

                                  ],
                                ),
                                Expanded(child: Container()),
                                Text((tripDirectionDetails != null) ? '${HelperMethods.estimateFares(tripDirectionDetails)} VND' : '', style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),),

                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 22,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[

                              Icon(FontAwesomeIcons.moneyBillAlt, size: 18, color: BrandColors.colorTextLight,),
                              SizedBox(width: 16,),
                              Text('Cash'),
                              SizedBox(width: 5,),
                              Icon(Icons.keyboard_arrow_down, color: BrandColors.colorTextLight, size: 16,),
                            ],
                          ),
                        ),

                        SizedBox(height: 22,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TaxiButton(
                            title: 'TÌM TÀI XẾ GẦN BẠN',
                            color: BrandColors.colorGreen,
                            onPressed: (){

                              // setState(() {
                              //   appState = 'REQUESTING';
                              // });
                              // showRequestingSheet();
                              //
                              // availableDrivers = FireHelper.nearbyDriverList;
                              //
                              // findDriver();

                            },
                          ),
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// Request Sheet
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: AnimatedSize(
            //     vsync: this,
            //     duration: new Duration(milliseconds: 150),
            //     curve: Curves.easeIn,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.black26,
            //             blurRadius: 15.0, // soften the shadow
            //             spreadRadius: 0.5, //extend the shadow
            //             offset: Offset(
            //               0.7, // Move to right 10  horizontally
            //               0.7, // Move to bottom 10 Vertically
            //             ),
            //           )
            //         ],
            //       ),
            //       //height: requestingSheetHeight,
            //       child: Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: <Widget>[
            //
            //             SizedBox(height: 10,),
            //
            //             SizedBox(
            //               width: double.infinity,
            //               // child: TextLiquidFill(
            //               //   text: 'Requesting a Ride...',
            //               //   waveColor: BrandColors.colorTextSemiLight,
            //               //   boxBackgroundColor: Colors.white,
            //               //   textStyle: TextStyle(
            //               //       color: BrandColors.colorText,
            //               //       fontSize: 22.0,
            //               //       fontFamily: 'Brand-Bold'
            //               //   ),
            //               //   boxHeight: 40.0,
            //               // ),
            //             ),
            //
            //             SizedBox(height: 20,),
            //
            //             GestureDetector(
            //               onTap: (){
            //                 // cancelRequest();
            //                 // resetApp();
            //               },
            //               child: Container(
            //                 height: 50,
            //                 width: 50,
            //                 decoration: BoxDecoration(
            //                   color: Colors.white,
            //                   borderRadius: BorderRadius.circular(25),
            //                   border: Border.all(width: 1.0, color: BrandColors.colorLightGrayFair),
            //
            //                 ),
            //                 child: Icon(Icons.close, size: 25,),
            //               ),
            //             ),
            //
            //             SizedBox(height: 10,),
            //
            //             Container(
            //               width: double.infinity,
            //               child: Text(
            //                 'Cancel ride',
            //                 textAlign: TextAlign.center,
            //                 style: TextStyle(fontSize: 12),
            //               ),
            //             ),
            //
            //
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),


          ],
        ),
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
        builder: (BuildContext context) => ProgressDialog(status: 'Please wait...',)
    );

    var thisDetails = await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();
    if(results.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

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

  resetApp(){

    setState(() {

      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      tripSheetHeight = 0;
      searchSheetHeight = 275;
      mapBottomPadding = 280;
      drawerCanOpen = true;

      // status = '';
      // driverFullName = '';
      // driverPhoneNumber = '';
      // driverCarDetails = '';
      // tripStatusDisplay = 'Driver is Arriving';

    });

    setupPositionLocator();

  }
}
