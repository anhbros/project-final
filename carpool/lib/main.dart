import 'dart:async';
import 'dart:io';
import 'package:carpool/dataprovider/AppData.dart';
import 'package:carpool/screens/loginpage.dart';
import 'package:carpool/screens/mainpage.dart';
import 'package:carpool/screens/registrationpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';




//using firebase database
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
      googleAppID: '1:668390133007:android:ea9313c6ce290a59c5827a',
      apiKey: 'AIzaSyD7O3yar4gkrhnucZM0Tpja2edBjcDQxwY',
      databaseURL: 'https://carpool-d8ac6-default-rtdb.firebaseio.com',
    ),
  );



  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Carpool',
        theme: ThemeData(
          fontFamily: 'Lexend-Regular',
          primarySwatch: Colors.blue,
        ),
        initialRoute : LoginPage.id,
        routes: {
          LoginPage.id : (Context) => LoginPage(),
          RegistrationPage.id :(Context) => RegistrationPage(),
          MainPage.id : (Context) => MainPage()
        },
      ),
    );
  }
}


