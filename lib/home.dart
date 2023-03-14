import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/font.dart';
import 'package:tflite/tflite.dart';
import 'camera.dart';

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  MyHomePage(this.cameras);
  @override
  _MyHomePageState createState() => _MyHomePageState();
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

  //TODO 1: Load Model
  loadTfliteModel() async {
    String res;
    res = (await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt"))!;
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
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("TensorFlow Lite App"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          //TODO 3: กล้องถ่าย
          Camera(widget.cameras, setRecognitions),

          //TODO 4: ตัวแสดงผลลัพธ์ความแม่นยำ
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
                            //TODO 4.1: Result A
                            ResultPrint(indexDT: 0, label: 'Apple', color: Colors.redAccent),
                            const SizedBox(height: 16.0),
                            //TODO 4.2: Result B
                            ResultPrint(indexDT: 1, label: 'Orange', color: Colors.orangeAccent),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  //==========================================================================================================
  Widget ResultPrint({required indexDT, required label, required Color color}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: styleFont20(Colors.redAccent)),
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
                      AlwaysStoppedAnimation<Color>(color),
                  value: index == indexDT ? confidence : 0.0,
                  backgroundColor: color.withOpacity(0.2),
                  minHeight: 50.0,
                ),
                //4.1.2 เปอร์เซ็นความถูกต้อง
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${index == indexDT ? (confidence * 100).toStringAsFixed(0) : 0} %',
                    style: styleFont20(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
