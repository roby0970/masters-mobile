import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:masters_mobile/home/HomePageController.dart';
import 'package:masters_mobile/models/BLEReading.dart';
import 'package:masters_mobile/models/Coordinate.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BLEController extends GetxController {
  RxInt xCoordinate = 0.obs;
  RxInt yCoordinate = 0.obs;
  RxBool loadingCoordinates = false.obs;
  final flutterReactiveBle = FlutterReactiveBle();
  static const String ble1 = "BLE #1";
  static const String ble2 = "BLE #2";
  static const String ble3 = "BLE #3";
  static const String ble4 = "BLE #4";
  static const String ble5 = "BLE #5";
  final Map<String, int> beacons = {
    ble1: 1,
    ble2: 2,
    ble3: 3,
    ble4: 4,
    ble5: 5,
  };

  Map<String, List<int>> beaconsAndRssi = {
    ble1: [0],
    ble2: [0],
    ble3: [0],
    ble4: [0],
    ble5: [0],
  };
  late Timer service;
  @override
  void onReady() {
    _startBleScan();
    _setupService();
    super.onReady();
  }

  List<BLEReading> getReadings() {
    Map<int, int> lastValues = {};

    beaconsAndRssi.forEach((key, value) {
      lastValues.addEntries([MapEntry(beacons[key]!, value.last)]);
    });

    List<BLEReading> readings = [];

    lastValues.removeWhere((key, value) => value == 0);
    lastValues.forEach((key, value) {
      readings.add(BLEReading(idBle: key, rssi: value));
    });

    return readings;
  }

  void _setupService() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String name = "Unknown";
    if (Platform.isAndroid) {
      try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          name = androidInfo.model!;
          } catch (e){
            name = "Android";
       }   
       
    }
    else if (Platform.isIOS) {
      try {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          name = iosInfo.utsname.machine!;
          } catch (e){
            name = "Android";
       }   
    }
    HomePageController homePageController = Get.find();
    service = Timer.periodic(Duration(milliseconds: 10000), (t) async {
      loadingCoordinates(true);
      //take most recent values of each beacon

      var requestbody = jsonEncode(<String, dynamic>{
        'name': name,
        'idspace' : homePageController.space.value.id,
        'source': getReadings(),
      });
      print("Sendgin request, $requestbody");

      var response = await http.post(
        Uri.parse(
            "http://${dotenv.env['IP_ADDR']}:${dotenv.env['PORT']}/coordinate"),
        headers: <String, String>{
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestbody,
      );
      print(response.body);
      Coordinate item = Coordinate.fromJson(json.decode(response.body));

      xCoordinate(item.x);
      yCoordinate(item.y);
      loadingCoordinates(false);
    });
  }

  void _startBleScan() {
    flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (beacons.keys.contains(device.name)) {
        if (beaconsAndRssi[device.name]!.length > 10)
          beaconsAndRssi[device.name]!.removeAt(0);
        beaconsAndRssi[device.name]!.add(device.rssi);
      }
    }, onError: (e) {
      print("err");
      print(e);
    });
  }

  @override
  void onClose() {
    super.onClose();
    //flutterReactiveBle.deinitialize();
  }
}
