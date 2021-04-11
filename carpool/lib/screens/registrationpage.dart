import 'package:carpool/brand_colors.dart';
import 'package:carpool/screens/loginpage.dart';
import 'package:carpool/screens/mainpage.dart';
import 'package:carpool/widgets/ProgressDialog.dart';
import 'package:carpool/widgets/TaxiButton.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {

  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser() async {

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Hệ thống đang ghi nhận...',),
    );

    //create account when get text from controller
    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).catchError((ex){

      //check error and display message
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);

    })).user;

    Navigator.pop(context);
    // check if user registration is successful
    if(user != null){

      DatabaseReference newUserRef = FirebaseDatabase.instance.reference().child('users/${user.uid}');

      //Prepare data to be saved on users table
      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };

      newUserRef.set(userMap);

      //Take the user to the mainPage
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);

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
                  image: AssetImage('images/carpool.png'),
                ),

                SizedBox(height: 40,),

                Text('Tạo tài khoản để sử dụng',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Lexend-Bold'),
                ),

                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[

                      // Fullname
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Full name',
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

                      // Email Address
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email address',
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


                      // Phone
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone number',
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

                      // Password
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
                        title: 'Đăng Ký',
                        color: BrandColors.colorGreen,
                        onPressed: () async{

                          //check network availability

                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('Không có kết nôi internet');
                            return;
                          }

                          //validate basic
                          if(fullNameController.text.length < 3){
                            showSnackBar('Vui lòng nhập đúng định dạng tên');
                            return;
                          }

                          if(phoneController.text.length < 10){
                            showSnackBar('Vui lòng nhập đúng định dạng số điện thoại');
                            return;
                          }

                          if(!emailController.text.contains('@')){
                            showSnackBar('Vui lòng nhập đúng định dạng email');
                            return;
                          }

                          if(passwordController.text.length < 8){
                            showSnackBar('Mật khẩu có độ dài không được nhỏ hơn 8 ký tự');
                            return;
                          }

                          registerUser();

                        },
                      ),

                    ],
                  ),
                ),

                FlatButton(
                    onPressed: (){
                      Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                    },
                    child: Text('Nếu bạn đã có tài khoản? Đăng nhập')
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}