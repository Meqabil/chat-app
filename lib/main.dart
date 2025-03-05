
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/auth/gate_page.dart';
import 'package:professional_chat/auth/signup.dart';
import 'package:professional_chat/auth/login.dart';
import 'package:professional_chat/chat/only_chat_rooms.dart';
import 'package:professional_chat/group/group_chat_page.dart';
import 'package:professional_chat/homepage.dart';
import 'package:professional_chat/list_users_only_admin.dart';
import 'package:professional_chat/themes/theme.dart';
import 'package:workmanager/workmanager.dart';

import 'chat/chat_page.dart';
import 'group/my_groups_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Background task executed: $task");
    return Future.value(true);
  });
}



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> setupInteractedMessage() async {

    RemoteMessage? event =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (event != null) {
      navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => ChatScreen(
        reciverId: event.data['otherId'],
        userImage: event.data['otherImage'],
        receiverName: event.data['otherName'],
        myId: event.data['myId'],
        myImage: event.data['myImage'],
        myName: event.data['myName'],
      ),
      ));
    }
  }

void _handleDynamicLinks() async {
  // Handle when app is opened from a terminated state
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  _processDynamicLink(initialLink);

  // Handle when app is already running
  FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    _processDynamicLink(dynamicLinkData);
  }).onError((error) {
    print('Error handling dynamic link: $error');
  });
}



void _processDynamicLink(PendingDynamicLinkData? data) async {
  if (data != null && data.link != null) {
    final Uri deepLink = data.link!;

    if (deepLink.queryParameters.containsKey('groupId')) {
      print("Dynamic link contains Group ID.");
      String groupId = deepLink.queryParameters['groupId']!;

      try {
        // Fetch group details from Firestore
        DocumentSnapshot groupDoc = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get();

        if (groupDoc.exists) {
          Map<String, dynamic> groupData = groupDoc.data() as Map<String, dynamic>;

          // Fetch admin name from Firestore
          String adminId = groupData['adminId'];
          QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: adminId)
              .get();

          String adminName = adminSnapshot.docs.isNotEmpty
              ? adminSnapshot.docs.first['name']
              : "Unknown Admin";

          // Extract group details
          String groupName = groupData['groupName'];
          String groupImage = groupData['groupCover'];
          int nthOfMembers = groupData['members'].length;
          List members = groupData['members'];

          // Navigate to CreateGroup with group details
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (context) => GroupChatPage(
                groupName: groupName,
                groupImage: groupImage,
                groupAdmin: adminId,
                currentUserId: FirebaseAuth.instance.currentUser!.uid,
                nthOfMembers: nthOfMembers,
                members: members,
                groupId: groupId,
              ),
            ),
          );
        } else {
          print("Group not found for ID: $groupId");
        }
      } catch (e) {
        print("Error fetching group data: $e");
      }
    }
  }
}



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ChatScreen(
      reciverId: event.data['otherId'],
      userImage: event.data['otherImage'],
      receiverName: event.data['otherName'],
      myId: event.data['myId'],
      myImage: event.data['myImage'],
      myName: event.data['myName'],
    ),
    ));
    print('3333333333333333333333333333333333333333333333333==================done');
    FirebaseFirestore.instance.collection('chatRooms').doc(event.data['chatId']).update({
      'unreadCount.${FirebaseAuth.instance.currentUser!.uid}': 0,
    });
  });
  setupInteractedMessage();
  _handleDynamicLinks();
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      navigatorKey: navigatorKey,
      routes: {
        "home" : (context) => const HomePage(),
        "login": (context) => const Login(),
        "signup": (context) => const SignUp(),
        'userlist': (context) => const ListUsersPage(),
        'yourgroups': (context) => const CreateGroup(),
        'chatrooms': (context) => const ChatRooms(),

      },
      home: Gate(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}


