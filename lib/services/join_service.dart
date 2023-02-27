import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JoinService {
  static Future<bool> join(HMSSDK hmssdk, {String role = "broadcaster"}) async {
    //TODO: Replace with your Room Id (Watch setup video here: https://www.youtube.com/watch?v=GJ94-BaszpQ&feature=youtu.be)
    String roomId = "632187104208780bf6630f3c";
    //TODO: Use your own Token endpoint (Watch setup video here: https://www.youtube.com/watch?v=GJ94-BaszpQ&feature=youtu.be)
    Uri endPoint = Uri.parse(
        "https://prod-in2.100ms.live/hmsapi/adityathakur.app.100ms.live/api/token");
    http.Response response = await http.post(endPoint,
        body: {'user_id': "user", 'room_id': roomId, 'role': role});
    var body = json.decode(response.body);
    if (body == null || body['token'] == null) {
      return false;
    }
    HMSConfig config = HMSConfig(authToken: body['token'], userName: "user");
    await hmssdk.join(config: config);
    return true;
  }
}
