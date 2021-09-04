import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:masters_mobile/controllers/HomePageController.dart';
import 'package:masters_mobile/models/BLEReading.dart';
import 'package:masters_mobile/models/Ble.dart';
import 'package:masters_mobile/models/Coordinate.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BLEController extends GetxController {
  final HomePageController homePageController = Get.find();
  RxInt xCoordinate = 0.obs;
  RxInt yCoordinate = 0.obs;
  RxBool loadingCoordinates = false.obs;
  final flutterReactiveBle = FlutterReactiveBle();



  Map<String, int> beacons = {
  };

  Map<String, List<int>> beaconsAndRssi = {

  };
  late Timer service;
  @override
  void onReady() {

    super.onReady();
  }
  void start() async {
    await _getBeaconInfo();
    _startBleScan();
    _setupService();
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
  Future<void> _getBeaconInfo() async  {
    final response = await http.get(
        Uri.parse(
            "http://${dotenv.env['IP_ADDR']}:${dotenv.env['PORT']}/bles_space/${homePageController.space.value.id}"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        );
    print(response.body);

    final items = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Ble> newBle = items.map<Ble>((json) {
      return Ble.fromJson(json);
    }).toList();
    int bleCount = 1;
    newBle.forEach((element) { 
      beacons.addAll({element.title! : bleCount++});
      beaconsAndRssi.addAll({element.title! : [0]});
    });
    print(beacons);
    print(beaconsAndRssi);

    

  }
  @override
  void onClose() {
    super.onClose();
    //flutterReactiveBle.deinitialize();
  }
}
