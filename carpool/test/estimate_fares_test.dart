import 'package:carpool/datamodels/DirectionDetails.dart';
import 'package:carpool/support/HelperMethods.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('Caculating estimate fares for trip', () {
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.distanceValue = 10;
    directionDetails.durationValue = 15;

    int actual = HelperMethods.estimateFares(directionDetails);
    int expectValue = 20165;
    expect(actual, expectValue);
  });

  test('Get direction details encoded points', () {
    LatLng startPosition = LatLng(21.0376713, 105.7816301);
    LatLng endPosition = LatLng(20.9999717, 105.8426663);
    String actual = '';
    HelperMethods.getEncodedPoints(startPosition, endPosition)
        .then((String value) {
      actual = value;
    });

    String expectValue = '';
    expect(actual, expectValue);
  });
  test('Get direction details list point', () {
    LatLng startPosition = LatLng(21.0376713, 105.7816301);
    LatLng endPosition = LatLng(20.9999717, 105.8426663);
    DirectionDetails directionDetails;
    HelperMethods.getDirectionDetails(startPosition, endPosition)
        .then((DirectionDetails value) {
      directionDetails = value;
    });

    String expectValue;
    expect(directionDetails, expectValue);
  });
}
