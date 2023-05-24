// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

List<CameraDescription> cameras = [];

/*Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}*/

/*class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Stream to YouTube',
      theme: ThemeData.dark(),
      home: const CameraScreen(),
    );
  }
}*/

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isStreaming = false;

  final String _streamKey =
      '97gt-2htv-dyme-4u5k-5uue'; // Replace with your YouTube stream key
  final String _streamURL =
      'rtmp://a.rtmp.youtube.com/live2'; // Replace with your YouTube stream URL

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getAccessToken();
  }

  Future<void> _initializeCamera() async {
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startStreaming() async {
    // Sign in with Google
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // Signed in successfully, continue with streaming setup
        final streamURL = '$_streamURL/$_streamKey';
        final streamHeaders = {
          'Authorization': 'Bearer ${_getAccessToken()}',
          'Content-Type': 'application/json',
        };

        // Rest of the streaming setup code...
        // ...
      } else {
        // Google sign-in was cancelled or failed
        print('Google sign-in was cancelled or failed.');
      }
    } catch (error) {
      // Error occurred during Google sign-in
      print('Error occurred during Google sign-in: $error');
    }
  }

  Future<void> _stopStreaming() async {
    _controller!.stopImageStream();
    setState(() {
      _isStreaming = false;
    });
  }

  void _sendImageData(String imageData) {
    final videoData = {
      'videoChunk': imageData,
      'streamKey': _streamKey,
    };

    // Send the video data to your custom backend or YouTube API
    // Example:
    // await http.post(Uri.parse('YOUR_BACKEND_URL'), body: json.encode(videoData));
    // Replace 'YOUR_BACKEND_URL' with the actual URL of your backend or YouTube API endpoint
    // You may need to import the 'dart:convert' package to encode the videoData as JSON.

    // Example code to print the videoData to the console
    print(videoData);
  }

  Future<String> _getAccessToken() async {
    // Get the access token from the authenticated Google user
    final GoogleSignInAuthentication googleAuth =
        await _googleSignIn.currentUser!.authentication;
    final accessToken = googleAuth.accessToken;
    return accessToken!;
  }

  String _processCameraImage(CameraImage image) {
    // Process the camera image and convert it to the desired format
    // Example:
    // Convert the image to base64 or any other desired format

    return '';
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
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2.5,
              child: CameraPreview(_controller!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isStreaming ? _stopStreaming : _startStreaming,
              child: Text(_isStreaming ? 'Stop Streaming' : 'Start Streaming'),
            ),
          ],
        ),
      ),
    );
  }
}
