import 'package:flutter/material.dart';
import 'package:professional_chat/notification/notify.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:professional_chat/notification/notification_service.dart';

class notif extends StatefulWidget {
  const notif({super.key});

  @override
  State<notif> createState() => _notifState();
}

class _notifState extends State<notif> {
  String? deviceToken;

  @override
  void initState() {
    super.initState();
    getDeviceToken();
  }

  Future<void> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    deviceToken = await messaging.getToken();
    print('Device Token: $deviceToken');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Test')),
      body: Container(
        child: InkWell(
          child: Text("Send Notification"),
          onTap: () async {
            if (deviceToken != null) {
              //await NotificationService.sendNotification(deviceToken!, 'Title', 'Body');
            } else {
              print('Device token is null');
            }
          },
        ),
      ),
    );
  }
} 