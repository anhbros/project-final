import 'package:carpool/brand_colors.dart';
import 'package:carpool/datamodels/Prediction.dart';
import 'package:carpool/dataprovider/AppData.dart';
import 'package:carpool/globalvariable.dart';
import 'package:carpool/support/RequestHelper.dart';
import 'package:carpool/widgets/BrandDivider.dart';
import 'package:carpool/widgets/PredictionTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController();

  var focusDestination = FocusNode();

  bool focused = false;

  void setFocus(){
    if(!focused){
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];

  void searchPlace(String placeName) async {

    if(placeName.length > 1){

      String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123254251&components=country:vn';
      var response = await RequestHelper.getRequest(url);

      if(response == 'failed'){
        return;
      }

      if(response['status'] == 'OK'){
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List).map((e) => Prediction.fromJson(e)).toList();

        setState(() {
          destinationPredictionList = thisList;
        });

      }

    }

  }

  @override
  Widget build(BuildContext context) {

    String address = Provider.of<AppData>(context).pickupAddress.placeName ?? '';
    pickupController.text = address;

    setFocus();

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 210,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ]
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
              child: Column(
                children: <Widget>[

                  SizedBox(height: 5,),
                  Stack(
                    children: <Widget>[
                      GestureDetector(
                          onTap:(){
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back)
                      ),
                      Center(
                        child: Text('Ch???n ??i???m ?????n',
                          style: TextStyle(fontSize: 20,fontFamily: 'Lexend-Bold' ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18,),

                  Row(
                    children: <Widget>[
                      Image.asset('images/pickicon.png', height: 16, width: 16,),

                      SizedBox(width: 18,),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding:  EdgeInsets.all(2.0),
                            child: TextField(
                              // onChanged: (value){
                              //   searchPlace(value);
                              // },
                              //focusNode: focusPickUpLocation,
                              controller: pickupController,
                              decoration: InputDecoration(
                                  hintText: '?????a ??i???m ????n',
                                  fillColor: BrandColors.colorLightGrayFair,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 10, top: 8, bottom: 8)
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 10,),

                  Row(
                    children: <Widget>[
                      Image.asset('images/desticon.png', height: 16, width: 16,),

                      SizedBox(width: 18,),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding:  EdgeInsets.all(2.0),
                            child: TextField(
                              onChanged: (value){
                                searchPlace(value);
                              },
                              focusNode: focusDestination,
                              controller: destinationController,
                              decoration: InputDecoration(
                                  hintText: 'B???n mu???n ?????n ????u?',
                                  fillColor: BrandColors.colorLightGrayFair,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 10, top: 8, bottom: 8)
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                ],
              ),
            ),
          ),

          (destinationPredictionList.length > 0) ?
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListView.separated(
              padding: EdgeInsets.all(0),
              itemBuilder: (context, index){
                return PredictionTile(
                  prediction: destinationPredictionList[index],
                );
              },
              separatorBuilder: (BuildContext context, int index) => BrandDivider(),
              itemCount: destinationPredictionList.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
            ),
          )
              : Container(),

        ],
      ),
    );
  }
}
