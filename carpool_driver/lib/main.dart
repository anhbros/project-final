import 'package:carpool_driver/dataprovider.dart';
import 'package:carpool_driver/globalvariabels.dart';
import 'package:carpool_driver/screens/login.dart';
import 'package:carpool_driver/screens/mainpage.dart';
import 'package:carpool_driver/screens/registration.dart';
import 'package:carpool_driver/screens/vehicleinfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:169450788828:ios:565f2d4b4623a7dbf9a119',
      gcmSenderID: '169450788828',
      databaseURL: 'https://geetaxi-9c60a.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:668390133007:android:ee8d6a3db505e3c3c5827a',
      apiKey: 'AIzaSyD7O3yar4gkrhnucZM0Tpja2edBjcDQxwY',
      databaseURL: 'https://carpool-d8ac6-default-rtdb.firebaseio.com',
    ),
  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        theme: ThemeData(

          fontFamily: 'Lexend-Regular',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
        routes: {
          MainPage.id: (context) => MainPage(),
          RegistrationPage.id: (context) => RegistrationPage(),
          VehicleInfoPage.id: (context) => VehicleInfoPage(),
          LoginPage.id: (context) => LoginPage(),
        },
      ),
    );
  }
}

