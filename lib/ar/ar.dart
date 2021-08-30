import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:masters_mobile/ar/ARController.dart';
import 'package:masters_mobile/models/ARCoordinate.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';

class LocalAndWebObjectsWidget extends StatefulWidget {
  LocalAndWebObjectsWidget({Key? key}) : super(key: key);
  @override
  _LocalAndWebObjectsWidgetState createState() =>
      _LocalAndWebObjectsWidgetState();
}

class _LocalAndWebObjectsWidgetState extends State<LocalAndWebObjectsWidget> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  late ARNode? localObjectNode;
  final ARController arController = Get.put(ARController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: onLocalObjectAtOriginButtonPressed,
                          child: Text("Add/Remove Local\nobject at Origin")),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) async {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          customPlaneTexturePath: "Images/triangle.png",
          showWorldOrigin: true,
          handleTaps: false,
        );
    this.arObjectManager.onInitialize();

    this.localObjectNode = ARNode(
        type: NodeType.localGLTF2,
        uri: "Models/Chicken_01/Chicken_01.gltf",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(0.0, 0.0, 2.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0));
  }

  Future<void> attachObjects() async {
    print("Attaching: ");
    for (int i = 1; i < arController.coordToShow.length; i + 2) {
      var newCoord = ARNode(
          type: NodeType.localGLTF2,
          uri: "Models/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(0, -1 * arController.coordToShow[i].y!,
              arController.coordToShow[i].x!),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
      print("Attaching: ${newCoord.position}");
      bool? res = await this.arObjectManager.addNode(newCoord);
      print(res);
    }
  }

  Future<void> onLocalObjectAtOriginButtonPressed() async {
    arController.getRoute();
    await attachObjects();
    /*this.arObjectManager.removeNode(this.localObjectNode!);

    var newNode = ARNode(
        type: NodeType.localGLTF2,
        uri: "Models/Chicken_01/Chicken_01.gltf",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(0.0, 0.0, 2.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0));
    bool? didAddLocalNode = await this.arObjectManager.addNode(newNode);
    this.localObjectNode = didAddLocalNode! ? newNode : null;*/
  }
}
