import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JoinService {
  static Future<bool> join(HMSSDK hmssdk) async {
    String roomId = "632187104208780bf6630f3c";
    Uri endPoint = Uri.parse(
        "https://prod-in2.100ms.live/hmsapi/adityathakur.app.100ms.live/api/token");
    http.Response response = await http.post(endPoint,
        body: {'user_id': "user", 'room_id': roomId, 'role': "broadcaster"});
    var body = json.decode(response.body);
    if (body == null || body['token'] == null) {
      return false;
    }
    HMSConfig config = HMSConfig(authToken: body['token'], userName: "user");
    await hmssdk.join(config: config);
    return true;
  }
}
