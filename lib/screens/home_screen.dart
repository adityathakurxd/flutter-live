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
  Future<bool> joinRoom({String role = "broadcaster"}) async {
    setState(() {
      _isLoading = true;
    });

    //Calling build method here
    await SdkInitializer.hmssdk.build();

    //The join method initialize sdk,gets auth token,creates HMSConfig and helps in joining the room
    bool isJoinSuccessful =
        await JoinService.join(SdkInitializer.hmssdk, role: role);
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
        body: 
        _isLoading?
        const CircularProgressIndicator(strokeWidth: 2,)
        :
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width,),
            OutlinedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  )),
              onPressed: () async {
                bool isJoined = await joinRoom();

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
                child:Text('Go Live!'),
              ),
            ),

            //Viewer
            OutlinedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  )),
              onPressed: () async {
                //Joining the room as hls-viewer
                bool isJoined = await joinRoom(role: "hls-viewer");

                if (isJoined) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ListenableProvider.value(
                          value: _dataStore, child: const StreamViewScreen())));
                } else {
                  const snackBar = SnackBar(
                    content: Text('Error in joining room and viewing.'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Padding(
                padding:  EdgeInsets.symmetric(horizontal: 55),
                child:  Text('View Live Stream'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
