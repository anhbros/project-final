
import 'package:carpool/brand_colors.dart';
import 'package:carpool/datamodels/Address.dart';
import 'package:carpool/datamodels/Prediction.dart';
import 'package:carpool/dataprovider/AppData.dart';
import 'package:carpool/support/RequestHelper.dart';
import 'package:carpool/widgets/ProgressDialog.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:carpool/globalvariable.dart';


class PredictionTile extends StatelessWidget {

  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(String placeID, context) async {

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Vui lòng chờ...',)
    );

    String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if(response == 'failed'){
      return;
    }

    if(response['status'] == 'OK'){

      Address thisPlace = Address();
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeID;
      thisPlace.latitude = response ['result']['geometry']['location']['lat'];
      thisPlace.longitude = response ['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false).updateDestinationAddress(thisPlace);
      print(thisPlace.placeName);

      Navigator.pop(context, 'getDirection');
    }

  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        getPlaceDetails(prediction.placeId, context);
      },
      padding: EdgeInsets.all(0),
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children: <Widget>[
                Icon(OMIcons.locationOn, color: BrandColors.colorDimText,),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(prediction.mainText, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16),),
                      SizedBox(height: 2,),
                      Text(prediction.secondaryText, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: BrandColors.colorDimText),),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 8,),

          ],
        ),
      ),
    );
  }
}