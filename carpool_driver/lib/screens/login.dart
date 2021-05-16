import 'package:carpool_driver/brand_colors.dart';
import 'package:carpool_driver/screens/mainpage.dart';
import 'package:carpool_driver/screens/registration.dart';
import 'package:carpool_driver/widgets/ProgressDialog.dart';
import 'package:carpool_driver/widgets/TaxiButton.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {

  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login() async {

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Đang đăng nhập',),
    );

    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).catchError((ex){
      switch (ex.code.toString()) {
        case "ERROR_USER_NOT_FOUND":
          {
            showSnackBar("Email không xác định , vui lòng nhập lại.");
            break;
          }
        case "ERROR_WRONG_PASSWORD":
          {
            showSnackBar("Bạn đã nhập sai mật khẩu , vui lòng nhập lại.");
            break;
          }
        default : {
          showSnackBar("Thông tin tài khoản của bạn đã bị sai.");
        }
      }
      Navigator.pop(context);
      //check error and display message
      // Navigator.pop(context);
      // PlatformException thisEx = ex;
      // showSnackBar(thisEx.message);

    })).user;

    if(user != null){
      // verify login
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');
      userRef.once().then((DataSnapshot snapshot) {

        if(snapshot.value != null){
          Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
        }
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 70,),
                Image(
                  alignment: Alignment.center,
                  height: 100.0,
                  width: 100.0,
                  image: AssetImage('images/car-sharing.png'),
                ),

                SizedBox(height: 40,),

                Text('Ứng dụng cho tài xế',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Lexend-Bold'),
                ),

                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 10,),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 40,),

                      TaxiButton(
                        title: 'Đăng nhập',
                        color: BrandColors.colorAccentPurple,
                        onPressed: () async {

                          //check network availability

                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('Không có kết nối internet');
                            return;
                          }

                          if(!emailController.text.contains('@')){
                            showSnackBar('Vui lòng nhập đúng định dạng email');
                            return;
                          }

                          if(passwordController.text.length < 8){
                            showSnackBar('Vui lòng nhập đúng số ký tự mật khẩu');
                            return;
                          }

                          login();

                        },
                      ),

                    ],
                  ),
                ),

                FlatButton(
                    onPressed: (){
                      Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                    },
                    child: Text('Nếu bạn chưa có tài khoản, vui lòng tạo tại đây')
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

