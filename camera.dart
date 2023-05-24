import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

List<CameraDescription> cameras = [];

class CameraWidget extends StatefulWidget {
  const CameraWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController controller;
  bool isStreaming = false;
  int cameraIndex = 0;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      cameras = value;
      controller =
          CameraController(cameras[cameraIndex], ResolutionPreset.high);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  void startStreaming() async {
    setState(() {
      isStreaming = true;
    });
    controller.startImageStream((CameraImage image) {
      String base64Image = base64Encode(image.planes.first.bytes);
      sendData(base64Image);
      logger.d("Image Streaming"); // Log message
    }).whenComplete(() {
      setState(() {
        isStreaming = false;
      });
    });
  }

  void sendData(String base64Image) async {
    String streamKey =
        '97gt-2htv-dyme-4u5k-5uue'; // Replace with your YouTube stream key
    var url = 'rtmp://a.rtmp.youtube.com/live2/$streamKey';
    var response = await http.post(Uri.parse(url),
        body: json.encode({'video': base64Image}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      logger.d('Live stream sent successfully');
    } else {
      logger.w('Error sending live stream: ${response.reasonPhrase}');
    }
  }

  void stopStreaming() {
    controller.stopImageStream();
    setState(() {
      isStreaming = false;
    });
  }

  void toggleCamera() async {
    await controller.dispose();
    cameraIndex = cameraIndex == 0 ? 1 : 0;
    controller = CameraController(cameras[cameraIndex], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isStreaming ? null : startStreaming,
              child: const Text('Start Live Stream'),
            ),
            const SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: isStreaming ? stopStreaming : null,
              child: const Text('Stop Live Stream'),
            ),
            const SizedBox(width: 16.0),
            Material(
              child: IconButton(
                onPressed: () => toggleCamera(),
                // ignore: unnecessary_null_comparison
                icon: Icon(controller != null
                    ? Icons.switch_camera
                    : Icons.switch_camera_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
