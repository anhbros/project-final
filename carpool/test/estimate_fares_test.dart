import 'package:carpool/datamodels/DirectionDetails.dart';
import 'package:carpool/support/HelperMethods.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:carpool/globalvariable.dart';

@GenerateMocks([http.Client])
void main() {
  test('Caculating estimate fares for trip', () {
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.distanceValue = 10;
    directionDetails.durationValue = 15;

    int actual = HelperMethods.estimateFares(directionDetails);
    int expectValue = 20165;
    expect(actual, expectValue);
  });
  test('Get direction details encoded points', () async {
    LatLng startPosition = LatLng(21.0376713, 105.7816301);
    LatLng endPosition = LatLng(20.9999717, 105.8426663);
    String actual = '';
    String encode =
        'w{k_CeosdSp@`@NELMJU@W@Y~@@?~@B~@ItAE\\ITIh@BVFZpAFrB?nBH`Fl@tD\\jDTPGp@@NCDEpCZb@D|Hv@fCTnIx@fHp@tBLbAD|@?nCIbBOzAUvAYfA[|CmAjCuA`D{B|JuHlIwGxNsKbDiCnDkCnQiNfDgCnP_MtUeQzFaEr\\{VFEBB@?NEnA{@fFsDjA{@b@SH?r@g@tBeBp@e@`@OzAeAz@o@[i@s@kAyAuB_EmGcBqCKGG?IMwAyBiCiEyCwEm@aAuGcLmEcIaBsCcCcEsIaO}B{Dc@_AwB}Cc@m@g@yCEOXmBZwApB_Lv@iE`@oC\\wCHaAFi@b@aCR}@p@kCf@kBbAuDrC{Pb@wC`@kDfAuMLKFUl@uDv@kFb@gCJ]DGNeAJo@f@uD}@G}A?qGEIc@t@SAUEIMI@sC';

    final client = MockClient((request) async { return http.Response(encode,200);});
    
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';
    when(client.get(url)).thenAnswer((_) async => http.Response(encode, 200));
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
