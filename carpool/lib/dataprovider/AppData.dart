

import 'package:carpool/datamodels/Address.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AppData extends ChangeNotifier{
  Address pickupAddress;

  Address destinationAddress;

  void updatePickupAddress(Address pick) {
    pickupAddress = pick;
    notifyListeners();
  }
  void updateDestinationAddress (Address destination){
    destinationAddress = destination;
    notifyListeners();
  }
}