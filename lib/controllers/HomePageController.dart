import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:masters_mobile/controllers/BLEController.dart';
import '../models/poi.dart';
import '../models/space.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePageController extends GetxController {
  Rx<Space> space = Space().obs;
  RxString message = "".obs;
  RxBool loadingPosition = true.obs;
  RxBool loadingPoi = true.obs;
  RxList<Poi> pois = List<Poi>.empty().obs;
  RxInt selectedPoi = 0.obs;
  @override
  void onReady() {
    getPos();
    super.onReady();
  }

  Future<void> getSpace(double long, double lat) async {
    final response = await http.post(
        Uri.parse(
            "http://${dotenv.env['IP_ADDR']}:${dotenv.env['PORT']}/spaces/find"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        body: jsonEncode({"x": long, "y": lat}));
    print(response.body);
    final item = json.decode(response.body);

    Space s = Space.fromJson(item);
    space(s);
    getPois();
  }

  Future<void> getPois() async {
    loadingPoi(true);
    final response = await http.get(
        Uri.parse(
            "http://${dotenv.env['IP_ADDR']}:${dotenv.env['PORT']}/pois_space/${space.value.id}"),
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        });

    final items = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Poi> newPois = items.map<Poi>((json) {
      return Poi.fromJson(json);
    }).toList();

    pois.clear();
    pois.addAll(newPois);
    loadingPoi(false);
    print(pois);
  }

  void getPos() async {
    loadingPosition(true);

    Position position = await _determinePosition().onError((error, stackTrace) {
      message(error as String);
      return Position(
          longitude: 999,
          latitude: 999,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
    });

    if (position.longitude != 999 && position.latitude != 999) {
      await getSpace(position.latitude, position.longitude);
      BLEController ble = Get.find();
      ble.start();
      loadingPosition(false);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
