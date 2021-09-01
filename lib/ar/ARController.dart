import 'dart:convert';

import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:masters_mobile/ble/BLEController.dart';
import 'package:masters_mobile/compass/CompassController.dart';
import 'package:masters_mobile/home/HomePageController.dart';
import 'package:http/http.dart' as http;
import 'package:masters_mobile/models/ARCoordinate.dart';

class ARController extends GetxController {
  RxList<ARCoordinate> coordToShow = RxList<ARCoordinate>.empty();
  RxList<ARNode> attachedNodes = RxList<ARNode>.empty();
  @override
  void onReady() {
    getRoute();
    super.onReady();
  }

  void getRoute() async {
    final HomePageController homePageController = Get.find();
    final CompassController compassController = Get.find();
    final BLEController bleController = Get.find();

    var requestbody = jsonEncode(<String, dynamic>{
      'id': "Robert S",
      "compass": compassController.compassValue.value,
      "space": homePageController.space.value.id,
      "destination_poi": homePageController.selectedPoi.value,
      'source': bleController.getReadings(),
      'finished': false,
    });
    print("Sendgin request, $requestbody");

    var response = await http.post(
      Uri.parse(
          "http://${dotenv.env['IP_ADDR']}:${dotenv.env['PORT']}/startroute"),
      headers: <String, String>{
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestbody,
    );
    print(response.body);
    final items = json.decode(response.body);
    List<ARCoordinate> newCoords = items.map<ARCoordinate>((json) {
      print(json);
      return ARCoordinate.fromJson(json);
    }).toList();

    coordToShow.clear();
    int i = 1;
    newCoords.forEach((element) {
      if ( i != 0)coordToShow.add(element);
      i++;
    });
    print(newCoords);
    //coordToShow.addAll(newCoords);
  }
}
