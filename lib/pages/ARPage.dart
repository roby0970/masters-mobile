import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:get/get.dart';
import 'package:masters_mobile/controllers/ARController.dart';
import 'package:masters_mobile/models/ARCoordinate.dart';
import 'package:vector_math/vector_math_64.dart';

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
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(icon: Icon(Icons.disabled_by_default_rounded), color: Color(0xffffff) 
               , iconSize: 30
              , onPressed: () {
              Get.back();
            },)),
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
                          child: Text("AddLocal\nobject at Origin")),
                          ElevatedButton(
                          onPressed: clearObjects,
                          child: Text("Remove Local\nobject at Origin")),
                          ElevatedButton(
                          onPressed: destroy,
                          child: Text("Destroz")),
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
  void destroy() {
    arController.attachedNodes.clear();
    arController.coordToShow.clear();
    Get.back();
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

    /*this.localObjectNode = ARNode(
        type: NodeType.localGLTF2,
        uri: "Models/Chicken_01/Chicken_01.gltf",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(0.0, 0.0, 2.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0));*/
  }

  Future<void> attachObjects() async {
    print(arController.coordToShow);
    Future.forEach<ARCoordinate>(arController.coordToShow, (element) async {
      print(element);
      var newCoord = ARNode(
          type: NodeType.localGLTF2,
          uri: "Models/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(element.x! ,0.0, - element.y!),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
      print("Attaching: ${newCoord.position}");
      bool? res = await this.arObjectManager.addNode(newCoord);
      arController.attachedNodes.add(newCoord);
      print(res);
    });
    
  }
  //arController.coordToShow[i].y!, 0, arController.coordToShow[i].x!
  Future<void> clearObjects() async {
    
    print("Clearing: ");
    for (int i = 0; i < arController.attachedNodes.length; i + 1) {
      
      bool? res = await this.arObjectManager.removeNode(arController.attachedNodes[i]);
      arController.attachedNodes.removeAt(i);
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
