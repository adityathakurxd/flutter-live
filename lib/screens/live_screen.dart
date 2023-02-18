import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';
import '../models/data_store.dart';
import '../services/sdk_initializer.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({Key? key}) : super(key: key);

  @override
  _LiveScreenState createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  bool isLocalAudioOn = true;
  bool isLocalVideoOn = true;
  Offset position = const Offset(10, 10);

  @override
  Widget build(BuildContext context) {
    final _isVideoOff = context.select<UserDataStore, bool>(
        (user) => user.remoteVideoTrack?.isMute ?? true);
    final remoteTrack = context
        .select<UserDataStore, HMSTrack?>((user) => user.remoteVideoTrack);

    return WillPopScope(
      onWillPop: () async {
        context.read<UserDataStore>().leaveRoom();
        if (context.read<UserDataStore>().isLive == false) {
          Navigator.pop(context);
        }
        return true;
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
                    child: _isVideoOff
                        ? const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.videocam_off,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        : (remoteTrack != null)
                            ? HMSVideoView(
                                track: remoteTrack as HMSVideoTrack,
                                matchParent: false)
                            : const Center(child: Text("No Video"))),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            context.read<UserDataStore>().leaveRoom();
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withAlpha(60),
                                    blurRadius: 3.0,
                                    spreadRadius: 5.0,
                                  ),
                                ]),
                            child: const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.call_end, color: Colors.white),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => {
                            SdkInitializer.hmssdk.toggleCameraMuteState(),
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                Colors.transparent.withOpacity(0.2),
                            child: Icon(
                              isLocalVideoOn
                                  ? Icons.videocam
                                  : Icons.videocam_off_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => {
                            SdkInitializer.hmssdk
                                .switchAudio(isOn: isLocalAudioOn),
                            setState(() {
                              isLocalAudioOn = !isLocalAudioOn;
                            })
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                Colors.transparent.withOpacity(0.2),
                            child: Icon(
                              isLocalAudioOn ? Icons.mic : Icons.mic_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
                    onTap: () {
                      context.read<UserDataStore>().leaveRoom();
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      if (isLocalVideoOn) {
                        SdkInitializer.hmssdk.switchCamera();
                      }
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent.withOpacity(0.2),
                      child: const Icon(
                        Icons.switch_camera_outlined,
                        color: Colors.white,
                      ),
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
