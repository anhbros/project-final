import 'package:carpool_driver/datamodels/Address.dart';
import 'package:carpool_driver/datamodels/history.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier{
  Address pickupAddress;

  Address destinationAddress;


  String earnings = '0';
  int tripCount = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistory = [];

  void updateEarnings(String newEarnings){
    earnings = newEarnings;
    notifyListeners();
  }

  void updateTripCount(int newTripCount){
    tripCount = newTripCount;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys){
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistory(History historyItem){
    tripHistory.add(historyItem);
    notifyListeners();
  }

  void updatePickupAddress(Address pick) {
    pickupAddress = pick;
    notifyListeners();
  }
  void updateDestinationAddress (Address destination){
    destinationAddress = destination;
    notifyListeners();
  }
}