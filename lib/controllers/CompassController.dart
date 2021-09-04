import 'package:get/get.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassController extends GetxController {
  RxDouble compassValue = 0.0.obs;

  @override
  void onReady() {
    FlutterCompass.events!.listen((event) {
      compassValue(event.heading);
    });
    super.onReady();
  }
}
