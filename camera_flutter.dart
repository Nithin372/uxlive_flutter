// Modify or Test on fluttercamera.dart
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sdp_transform/sdp_transform.dart';

class LiveStream extends StatefulWidget {
  const LiveStream({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LiveStreamState createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  late MediaStream _localStream;
  late RTCPeerConnection _peerConnection;

  final String _youtubeStreamURL =
      "rtmp://a.rtmp.youtube.com/live2/"; // YouTube RTMP URL

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<MediaStream> _createStream() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);
    _localRenderer.srcObject = stream;
    return stream;
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun.l.google.com:19302',
          ]
        }
      ]
    };

    final peerConnection = await createPeerConnection(configuration);
    peerConnection.addStream(_localStream);
    peerConnection.onAddStream = (stream) {
      _remoteRenderer.srcObject = stream;
    };
    return peerConnection;
  }

  startStream() async {
    _localStream = await _createStream();
    _peerConnection = await _createPeerConnection();
    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    // Send the offer to a signaling server or a WebRTC server
    // ...

    // After receiving answer from signaling server or WebRTC server
    // Set the remote description and start streaming
    // ...

    // Get the YouTube stream key from your server or input it directly
    String streamKey =
        await getYouTubeStreamKey(); // Replace with your own logic

    // Start streaming to YouTube
    String youtubeStreamURL = _youtubeStreamURL + streamKey;
    await _peerConnection.addStream(_localStream);
    await _peerConnection.createOffer().then((offer) {
      return _peerConnection.setLocalDescription(offer);
    });
    var localDescription = await _peerConnection.getLocalDescription();
    var sdp = parse(localDescription!.sdp.toString());
    var url = '$youtubeStreamURL/$streamKey';
    await http.post(Uri.parse(url), body: json.encode(sdp));
  }

  stopStream() async {
    await _peerConnection.close();
    await _localStream.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
  }

  Future<String> getYouTubeStreamKey() async {
    // Replace with your own logic to get YouTube stream key
    // This could be an API call to your server, or user input, etc.
    String streamKey = '97gt-2htv-dyme-4u5k-5uue';
    return streamKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream to YouTube'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_localRenderer),
          ),
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
          ElevatedButton(
            onPressed: startStream,
            child: const Text('Start Streaming'),
          ),
          ElevatedButton(
            onPressed: stopStream,
            child: const Text('Stop Streaming'),
          ),
        ],
      ),
    );
  }
}

//This code only captures video from the device's camera and sends it to a WebRTC server. 

//Set up camera capture: Use the Flutter camera plugin or any other relevant plugin to capture video from the device's camera in your Flutter app.

//Set up WebRTC integration: Use a WebRTC plugin or library for Flutter, such as flutter-webrtc, to establish a connection with a signaling server or a custom WebRTC server.

//Configure signaling/WebRTC server: Configure the signaling server or WebRTC server to handle the streaming to YouTube. This may involve setting up a pipeline or media element to take the captured video stream from the Flutter app and send it to YouTube using the stream key.

//Authenticate and authorize: Obtain the necessary API credentials for the YouTube API, authenticate your Flutter app, and authorize it to access the YouTube API for obtaining the stream key. You can refer to the official YouTube API documentation for details on how to obtain API credentials and authenticate your app.

//Obtain stream key: Use the YouTube API to obtain the stream key for your YouTube channel or live event. The stream key is a unique identifier that YouTube uses to identify your live stream.

//Start and stop streaming: Implement logic in your Flutter app to start and stop the streaming process. This may involve sending commands to your signaling server or WebRTC server to start or stop sending the video stream to YouTube using the obtained stream key. 




