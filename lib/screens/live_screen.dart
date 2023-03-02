import 'package:flutter/material.dart';
import 'package:flutterlive/screens/view_live.dart';
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
    final _isVideoOff = context
        .select<UserDataStore, bool>((user) => user.localTrack?.isMute ?? true);
    final remoteTrack = context
        .select<UserDataStore, HMSVideoTrack?>((user) => user.remoteVideoTrack);
    final localTrack = context
        .select<UserDataStore, HMSVideoTrack?>((user) => user.localTrack);

    final isLive =
        context.select<UserDataStore, bool?>((user) => user.isLive) ?? false;

    return WillPopScope(
      onWillPop: () async {
        context.read<UserDataStore>().leaveRoom();
        Navigator.pop(context);
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            child: isLive
                ? Stack(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
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
                              : Column(
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.5,
                                        child: (localTrack != null &&
                                                !localTrack.isMute)
                                            ? HMSVideoView(
                                                track:
                                                    localTrack as HMSVideoTrack,
                                                matchParent: false,
                                                scaleType:
                                                    ScaleType.SCALE_ASPECT_FILL,
                                              )
                                            : const Center(
                                                child: Text(
                                                "No Video",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ))),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.5,
                                        child: (remoteTrack != null &&
                                                !remoteTrack.isMute)
                                            ? HMSVideoView(
                                                track: remoteTrack,
                                                matchParent: false,
                                                scaleType:
                                                    ScaleType.SCALE_ASPECT_FILL,
                                              )
                                            : const Center(
                                                child: Text(
                                                "No Video",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )))
                                  ],
                                )),
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
                                    child: Icon(Icons.call_end,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => {
                                  SdkInitializer.hmssdk.toggleCameraMuteState(),
                                  setState(() {
                                    isLocalVideoOn = !isLocalVideoOn;
                                  })
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
                                  SdkInitializer.hmssdk.toggleMicMuteState(),
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
                            backgroundColor:
                                Colors.transparent.withOpacity(0.2),
                            child: const Icon(
                              Icons.switch_camera_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (isLive)
                        Positioned(
                            bottom: 80,
                            right: 5,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 10,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Stream is running",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ))
                    ],
                  )
                : Container(
                    color: Colors.black,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(
                          height: 20,
                        ),
                        const Padding(
                          padding:  EdgeInsets.symmetric(horizontal:15.0),
                          child:  Text(
                            "Stream is starting currently Please wait. If it doesn't start automatically press the button below",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        OutlinedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              )),
                          onPressed: () async {
                            context.read<UserDataStore>().startHLSStreaming();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text('Go Live!'),
                          ),
                        ),
                      ],
                    ))),
          ),
        ),
      ),
    );
  }
}
