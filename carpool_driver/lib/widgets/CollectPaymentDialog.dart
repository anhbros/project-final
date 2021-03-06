import 'package:carpool_driver/brand_colors.dart';
import 'package:carpool_driver/helpers/helpermethods.dart';
import 'package:carpool_driver/widgets/BrandDivier.dart';
import 'package:carpool_driver/widgets/TaxiButton.dart';
import 'package:flutter/material.dart';

class CollectPayment extends StatelessWidget {

  final String paymentMethod;
  final int fares;

  CollectPayment({this.paymentMethod, this.fares});
  

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            SizedBox(height: 20,),

            Text('${paymentMethod.toUpperCase()} THANH TOÁN'),

            SizedBox(height: 20,),

            BrandDivider(),

            SizedBox(height: 16.0,),

            Text('$fares VND', style: TextStyle(fontFamily: 'Lexend-Bold', fontSize: 50),),

            SizedBox(height: 16,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Số tiền khách hàng đã trả', textAlign: TextAlign.center,),
            ),

            SizedBox(height: 30,),

            Container(
              width: 230,
              child: TaxiButton(
                title: (paymentMethod == 'cash') ? 'THU TIỀN' : 'XÁC NHẬN',
                color: BrandColors.colorGreen,
                onPressed: (){

                  Navigator.pop(context);
                  Navigator.pop(context);

                  HelperMethods.enableHomTabLocationUpdates();

                },
              ),
            ),

            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}
