import 'package:flutter/material.dart';
import 'package:flutterlive/screens/video_player.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';
import '../models/data_store.dart';
import '../services/sdk_initializer.dart';

class StreamViewScreen extends StatefulWidget {
  const StreamViewScreen({Key? key}) : super(key: key);

  @override
  _StreamViewScreenState createState() => _StreamViewScreenState();
}

class _StreamViewScreenState extends State<StreamViewScreen> {
  bool isLocalAudioOn = true;
  bool isLocalVideoOn = true;
  Offset position = const Offset(10, 10);

  Future<bool> leaveRoom() async {
    context.read<UserDataStore>().leaveRoom();
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final streamURL =
        context.select<UserDataStore, String?>((user) => user.streamURL);

    return WillPopScope(
      onWillPop: () async {
        return leaveRoom();
      },
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.9),
                  child: (streamURL != null)
                      ? VideoPlayerScreen(streamURL: streamURL)
                      : const Center(
                          child: Text(
                            "No Live Video",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
