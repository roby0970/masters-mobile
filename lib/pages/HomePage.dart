import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masters_mobile/pages/ARPage.dart';
import 'package:masters_mobile/controllers/CompassController.dart';
import '../controllers/BLEController.dart';
import '../controllers/HomePageController.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final homePageController = Get.put(HomePageController());
  final bleController = Get.put(BLEController());
  final compassController = Get.put(CompassController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      "NavinAR",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                  ),
                ),
                Obx(() => Text(compassController.compassValue.toString())),
                SizedBox(
                  height: 25,
                ),
                Obx(() {
                  return homePageController.loadingPosition.value
                      ? CircularProgressIndicator.adaptive()
                      : Text(
                          "${homePageController.space.value.title}",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 38),
                        );
                }),
                Obx(() {
                  return Text(
                    "( ${bleController.xCoordinate.value}, ${bleController.yCoordinate.value} )",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 38),
                  );
                }),
                SizedBox(
                  height: 40,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What you might find interesting",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 18),
                  ),
                ),
                Obx(() {
                  return homePageController.loadingPoi.value
                      ? Center(child: CircularProgressIndicator.adaptive())
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: homePageController.pois.length,
                          itemBuilder: (_, i) {
                            return ListTile(
                              title: Text(
                                homePageController.pois[i].title!,
                                style: TextStyle(fontSize: 20),
                              ),
                              subtitle: Container(
                                width: 30,
                                height: 5,
                                color: Color(homePageController.pois[i].color!),
                              ),
                              onTap: () {
                                homePageController
                                    .selectedPoi(homePageController.pois[i].id);

                                Get.to(LocalAndWebObjectsWidget());
                              },
                            );
                          });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
