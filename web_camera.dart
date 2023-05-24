import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Stream to YouTube',
      theme: ThemeData.dark(),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isStreaming = false;
  late StreamSubscription<VideoChunkEvent> _streamSubscription;

  final String _streamKey =
      'YOUR_STREAM_KEY'; // Replace with your YouTube stream key
  final String _streamURL =
      'YOUR_STREAM_URL'; // Replace with your YouTube stream URL

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startStreaming() async {
    final streamURL = '$_streamURL/$_streamKey';
    final streamHeaders = {
      'Authorization':
          'Bearer ${_getAccessToken()}', // Replace with your YouTube API access token
      'Content-Type': 'application/json',
    };

    await http
        .post(Uri.parse(streamURL), headers: streamHeaders)
        .then((response) {
      if (response.statusCode == 200) {
        _streamSubscription =
            _controller!.startVideoStreaming().listen((event) {
          final videoChunk = event as VideoChunkEvent;
          final chunkData = base64Encode(videoChunk.data);

          // Send the video chunk to YouTube
          _sendVideoChunk(chunkData);
        });

        setState(() {
          _isStreaming = true;
        });
      }
    });
  }

  Future<void> _stopStreaming() async {
    await _streamSubscription.cancel();
    _controller!.stopVideoStreaming();
    setState(() {
      _isStreaming = false;
    });
  }

  void _sendVideoChunk(String chunkData) {
    final videoData = {
      'videoChunk': chunkData,
      'streamKey': _streamKey,
    };

    // Send the video data to your custom backend or YouTube API
    // Example:
    // await http.post(Uri.parse('YOUR_BACKEND_URL'), body: json.encode(videoData));
  }

  String _getAccessToken() {
    // Implement your logic to obtain the YouTube API access token
    // Example:
    // final accessToken = await yourAuthLibrary.getAccessToken();
    // return accessToken;

    return 'YOUR_ACCESS_TOKEN'; // Replace with your YouTube API access token
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Stream to YouTube'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isStreaming ? _stopStreaming : _startStreaming,
            child: Text(_isStreaming ? 'Stop Streaming' : 'Start Streaming'),
          ),
        ],
      ),
    );
  }
}
