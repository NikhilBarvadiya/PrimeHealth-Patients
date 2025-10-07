import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class FirebaseService {
  Future<String> getAccessToken() async {
    try {
      final jsonString = await rootBundle.loadString('assets/service-account.json');
      final Map<String, dynamic> serviceAccount = json.decode(jsonString);
      final String clientEmail = serviceAccount['client_email'];
      final String privateKey = serviceAccount['private_key'].replaceAll(r'\n', '\n');
      final jwt = JWT({
        "iss": clientEmail,
        "scope": "https://www.googleapis.com/auth/firebase.messaging",
        "aud": "https://oauth2.googleapis.com/token",
        "exp": (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
        "iat": (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      });
      final token = jwt.sign(RSAPrivateKey(privateKey), algorithm: JWTAlgorithm.RS256);
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer', 'assertion': token},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<void> sendNotification(Map<String, dynamic> payload) async {
    String firebaseToken = await getAccessToken();
    if (firebaseToken.isNotEmpty) {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/testing-4b090/messages:send"),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $firebaseToken'},
        body: jsonEncode(payload),
      );
    }
  }
}

FirebaseService firebaseService = FirebaseService();
