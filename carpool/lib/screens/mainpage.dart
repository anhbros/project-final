import 'dart:async';

import 'package:carpool/brand_colors.dart';
import 'package:carpool/screens/searchpage.dart';
import 'package:carpool/support/HelperMethods.dart';
import 'package:carpool/widgets/BrandDivider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  var geoLocator = Geolocator();
  Position currentPosition;

  void setupPositionLocator() async{
    Position position = await geoLocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));


    String address = await HelperMethods.findCordinateAddress(position, context);
    print(address);
  }

  double mapBottomPadding = 0;
  bool drawerCanOpen = true;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(21.0344688, 105.7789208),
    zoom: 14.4746,
  );

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
                          Text('Anh Duc Nguyen', style: TextStyle(fontSize: 20, fontFamily: 'Lexend-Bold'),),
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

              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text('Quà tặng', style: TextStyle(fontSize: 16,),),
              ),

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
            GoogleMap(initialCameraPosition: _kGooglePlex , mapType: MapType.normal,
              padding: EdgeInsets.only(bottom: mapBottomPadding),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: (GoogleMapController controller){
                _controller.complete(controller);
                mapController = controller;

                setState(() {
                  mapBottomPadding = 280;
                });

                setupPositionLocator();
              },
            ) ,

            Positioned(
              top: 44,
              left: 20,
              child: GestureDetector(
                onTap: (){
                  // if(drawerCanOpen){
                      scaffoldKey.currentState.openDrawer();
                  // }
                  // else{
                  //   //resetApp();
                  // }
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
              child: Container(
                height: 280,
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
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
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
            )
          ],
        ),
    );
  }
}
