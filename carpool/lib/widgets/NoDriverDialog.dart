
import 'package:carpool/brand_colors.dart';
import 'package:carpool/widgets/TaxiOutlineButton.dart';
import 'package:flutter/material.dart';

class NoDriverDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding:  EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10,),

                Text('Không tìm thấy tài xê', style: TextStyle(fontSize: 22.0, fontFamily: 'Lexend-Bold'),),

                SizedBox(height: 25,),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Không tìm thấy tài xế trong bán kính 20km , bạn cần đến những nơi gần hơn để tìm tài xê', textAlign: TextAlign.center,),
                ),

                SizedBox(height: 30,),

                Container(
                  width: 200,
                  child: TaxiOutlineButton(
                    title: 'ĐÓNG',
                    color: BrandColors.colorLightGrayFair,
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ),

                SizedBox(height: 10,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}