import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

//คือการสร้างชนิดข้อมูลใหม่ ที่เป็นการรับค่าเป็น List ของ dynamic และไม่มีการ return ค่าออกมา
typedef void Callback(List<dynamic> list);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;

  //ค่าเริ่มต้นเมื่อเรียกใช้
  Camera(this.cameras, this.setRecognitions);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController cameraController;
  bool isDetecting = false;

  //TODO 0: เรียกใช้ทันทีเมื่อรันหน้านี้
  @override
  void initState() {
    super.initState();

    //เรียกใช้ฟังก์ชัน loadModel ที่อยู่ใน class นี้
    cameraController =
        CameraController(widget.cameras.first, ResolutionPreset.high);

    //รอการทำงานจนกว่าจะเสร็จ
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    //สตรีมรูปภาพที่จับภาพเฟรมจากกล้องอย่างต่อเนื่องและส่งต่อไปยังเมธอด Tflite.runModelOnFrame() สำหรับการตรวจจับวัตถุ
    cameraController.startImageStream((CameraImage image) {
      if (!isDetecting) {
        isDetecting = true;

        Tflite.runModelOnFrame(
          bytesList: image.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          numResults: 1,
        ).then((value) {
          if (value!.isNotEmpty) {
            widget.setRecognitions(value);
            isDetecting = false;
          }
        });
      }
    });
  }

  //TODO 1: ปิดการทำงานของ init()
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  //-------------------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    } else {
      //Transform.scale ถูกใช้เพื่อปรับขนาดตัวอย่างกล้องให้พอดีกับพื้นที่หน้าจอที่มีอยู่
      //AspectRatio ถูกใช้เพื่อตั้งค่าอัตราส่วนของตัวอย่างกล้องให้ตรงกับอัตราส่วนของวิดีโอของกล้อง 
      //ซึ่งจะต้องการทำเพื่อให้ตัวอย่างกล้องแสดงอย่างถูกต้องโดยไม่มีการเบี้ยวหรือตัดขอบ
      return Transform.scale(
        scale: 1 / cameraController.value.aspectRatio,
        child: AspectRatio(
          aspectRatio: cameraController.value.aspectRatio,
          child: CameraPreview(cameraController),
        ),
      );
    }
  }
}
