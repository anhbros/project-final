import 'package:carpool_driver/brand_colors.dart';
import 'package:carpool_driver/screens/login.dart';
import 'package:carpool_driver/widgets/AvailabilityButton.dart';
import 'package:carpool_driver/widgets/ConfirmSheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AvailabilityButton(
          title: 'ĐĂNG XUẤT',
          color: BrandColors.colorAccentPurple,
          onPressed: (){


            showModalBottomSheet(
              isDismissible: false,
              context: context,
              builder: (BuildContext context) => ConfirmSheet(
                title: 'ĐĂNG XUẤT',
                subtitle: 'Bạn có muốn đăng xuất khỏi ứng dụng không?',

                onPressed: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                },
              ),
            );

          },
        ),
      ],
    ));
  }
}
