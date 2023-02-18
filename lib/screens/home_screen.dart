import 'package:flutter/material.dart';
import 'package:flutterlive/screens/view_live.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/data_store.dart';
import '../services/join_service.dart';
import '../services/sdk_initializer.dart';
import 'live_screen.dart';
import 'video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserDataStore _dataStore;
  bool _isLoading = false;

  @override
  void initState() {
    SdkInitializer.hmssdk.build();
    getPermissions();
    super.initState();
  }

  void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  //Handles room joining functionality
  Future<bool> joinRoom() async {
    setState(() {
      _isLoading = true;
    });
    //The join method initialize sdk,gets auth token,creates HMSConfig and helps in joining the room
    bool isJoinSuccessful = await JoinService.join(SdkInitializer.hmssdk);
    if (!isJoinSuccessful) {
      return false;
    }
    _dataStore = UserDataStore();
    //Here we are attaching a listener to our DataStoreClass
    _dataStore.startListen();

    setState(() {
      _isLoading = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF2E80FF),
        body: Center(
          child: Column(
            children: [
              OutlinedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    )),
                onPressed: () async {
                  print("TRYING TO JOIN");
                  bool isJoined = await joinRoom();
                  print("$isJoined");
                  if (isJoined) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ListenableProvider.value(
                            value: _dataStore, child: const LiveScreen())));
                  } else {
                    const snackBar = SnackBar(
                      content: Text('Error in joining room and streaming.'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: Text('Go Live!'),
                ),
              ),
              // OutlinedButton(
              //   style: ButtonStyle(
              //       backgroundColor: MaterialStateProperty.all(Colors.white),
              //       shape: MaterialStateProperty.all(
              //         RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(40),
              //         ),
              //       )),
              //   onPressed: () async {
              //     // use onjoin
              //     bool isJoined = await joinRoom();
              //     if (isJoined) {
              //       Navigator.of(context).push(MaterialPageRoute(
              //           builder: (_) => ListenableProvider.value(
              //                 value: _dataStore,
              //                 child: StreamViewScreen(),
              //               )));
              //     } else {
              //       const SnackBar(content: Text("Error"));
              //     }
              //   },
              //   child: const Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 80),
              //     child: Text('Join Live!'),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
