import 'dart:async';

import 'package:carpool/brand_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('mainpage'),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(initialCameraPosition: _kGooglePlex , mapType: MapType.normal,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller){
                _controller.complete(controller);
                mapController = controller;
              },
            ) ,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 250,
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
                      SizedBox(height: 50,),
                      Text('Enjoy day ! Can I pick up you from here', style: TextStyle(fontSize: 10),),
                      Text('Where are you going to ?', style: TextStyle(fontSize: 18 , fontFamily: 'Brand-Bold'),),

                      SizedBox(height: 20,) ,

                      Container(
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
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.search , color: Colors.blueAccent,),
                            SizedBox(width : 10 ,),
                            Text('Your Destination')
                          ],
                        ),
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
