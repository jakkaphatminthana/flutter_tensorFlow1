import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/camera.dart';
import 'package:flutter_application_1/font.dart';
import 'package:tflite/tflite.dart';

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  MyHomePage(this.cameras);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String predOne = '';
  double confidence = 0;
  double index = 0;

  //TODO 0: Start init
  @override
  void initState() {
    super.initState();
    loadTfliteModel();
  }

  //TODO 1: Lode Model
  loadTfliteModel() async {
    String res;
    res = (await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/label.txt",
    ))!;
    print(res);
  }

  //TODO 2: Label ที่แสดงออกมา
  setRecognitions(outputs) {
    print(outputs);

    if (outputs[0]['index'] == 0) {
      index = 0;
    } else {
      index = 1;
    }

    confidence = outputs[0]['confidence'];
    setState(() {
      predOne = outputs[0]['label'];
    });
  }

  @override
  Widget build(BuildContext context) {
    //------------------------------------------------------------------------------------------------------------
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("TensorFlow Lite App"),
      ),
      body: Stack(
        children: [
          //TODO 3: กล้องถ่าย
          Camera(widget.cameras, setRecognitions),

          //TODO 4: ตัวแสดงผลลัพธ์
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                //TODO 4.1: Result A ------------------------
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Mass",
                                    style: styleFont20(Colors.greenAccent),
                                  ),
                                ),
                                const SizedBox(width: 16.0),

                                Expanded(
                                  flex: 8,
                                  child: SizedBox(
                                    height: 32.0,
                                    child: Stack(
                                      children: [
                                        //4.1.1 เส้นผลลัพธ์ความแม่นยำ
                                        LinearProgressIndicator(
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.greenAccent),
                                          value:
                                              (index == 0) ? confidence : 0.0,
                                          backgroundColor:
                                              Colors.greenAccent.withOpacity(0.2),
                                          minHeight: 50.0,
                                        ),
                                        //4.1.2 เปอร์เซ็นความถูกต้อง
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '${index == 0 ? (confidence * 100).toStringAsFixed(0) : 0} %',
                                            style: styleFont20(Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),

                            Row(
                              children: [
                                //TODO 4.1: Result B ------------------------
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "NoMass",
                                    style: styleFont20(Colors.redAccent),
                                  ),
                                ),
                                const SizedBox(width: 16.0),

                                Expanded(
                                  flex: 8,
                                  child: SizedBox(
                                    height: 32.0,
                                    child: Stack(
                                      children: [
                                        //4.1.1 เส้นผลลัพธ์ความแม่นยำ
                                        LinearProgressIndicator(
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.redAccent),
                                          value:
                                              (index == 0) ? confidence : 0.0,
                                          backgroundColor:
                                              Colors.redAccent.withOpacity(0.2),
                                          minHeight: 50.0,
                                        ),
                                        //4.1.2 เปอร์เซ็นความถูกต้อง
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '${index == 0 ? (confidence * 100).toStringAsFixed(0) : 0} %',
                                            style: styleFont20(Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
