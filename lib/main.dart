import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(cameras),
    ),
  );
}
