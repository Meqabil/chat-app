import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/chat/chat_page.dart';
import 'package:badges/badges.dart' as badges;
import '../widgets/mydrawer.dart';

class ChatRooms extends StatefulWidget {
  const ChatRooms({super.key});

  @override
  State<ChatRooms> createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  userState(){
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("signup");
      }
    });
  }
  final currentUser =  FirebaseAuth.instance.currentUser!.uid;

  String myName = '';
  String myImage = '';
  getCurrentUserData() async{
    try{
      FirebaseAuth auth = FirebaseAuth.instance;
      CollectionReference data = FirebaseFirestore.instance.collection('users');
      QuerySnapshot myData = await data.where('uid',isEqualTo: auth.currentUser!.uid).get();
      if(myData.docs.isNotEmpty){
        var currentUserData = myData.docs.first;
        myName = currentUserData['name'];
        myImage = currentUserData['image'];
      } else{
        myImage = 'Unknown';
        myName = 'Unknown';
      }
    }catch(e){
      print(e);
    }
  }


  Future<void> getDeviceTokenAndUpdateFirestore() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? newToken = await messaging.getToken();

    if (newToken != null) {
      // Assuming you store each user document in Firestore under their user ID
      String userId = currentUser; // Replace with actual user ID
      QuerySnapshot userRef = await FirebaseFirestore.instance.collection('users').where('uid',isEqualTo: currentUser).get();
      var token =userRef.docs.first.id;
      await FirebaseFirestore.instance.collection('users').doc(token).update(
          {
            'token':newToken,
          });
      print('Device token updated in Firestore: $newToken');
    } else {
      print('Failed to get device token');
    }
  }

  requestForPermessions() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userState();
    getCurrentUserData();
    getDeviceTokenAndUpdateFirestore();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Rooms"),
        centerTitle: true,

      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('home');
        },
        label: Row(
          children: [Icon(Icons.chat), Text(' New Chat')],
        ),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chatRooms')
            .where('users', arrayContains: currentUser)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var data = snapshot.data!.docs;
          return ListView.builder(
              itemBuilder: (context, index) {
                final unreadCount = data[index]['unreadCount'][currentUser] ?? 0;

                return  Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data[index]['myId'] == currentUser ? data[index]['otherImage'] : data[index]['myImage']),
                      radius: 30,
                    ),
                    title: Text(
                      data[index]['myId'] == currentUser ? data[index]['otherName'] : data[index]['myName'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('  ${data[index]['lastMessage']}',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(
                      color: Colors.grey.shade400
                    ),),
                    trailing: unreadCount > 0
                        ? badges.Badge(
                      badgeContent: Text(
                        unreadCount.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.of(context).push(
                        _createRoute(ChatScreen(
                          reciverId: data[index]['myId'] == currentUser ? data[index]['otherId'] : data[index]['myId'],
                          userImage: data[index]['myId'] == currentUser ? data[index]['otherImage'] : data[index]['myImage'],
                          receiverName: data[index]['myId'] == currentUser ? data[index]['otherName'] : data[index]['myName'],
                          myName: myName,
                          myImage: myImage,
                          myId: currentUser,
                        ))
                        // MaterialPageRoute(
                        //   builder: (context) => ChatScreen(
                        //     reciverId: data[index]['myId'] == currentUser ? data[index]['otherId'] : data[index]['myId'],
                        //     userImage: data[index]['myId'] == currentUser ? data[index]['otherImage'] : data[index]['myImage'],
                        //     receiverName: data[index]['myId'] == currentUser ? data[index]['otherName'] : data[index]['myName'],
                        //     myName: myName,
                        //     myImage: myImage,
                        //     myId: currentUser,
                        //   ),
                        // ),
                      );

                      //Reset unread count for this user
                      FirebaseFirestore.instance.collection('chatRooms').doc(data[index].id).update({
                        'unreadCount.${currentUser}': 0,
                      });
                    },
                  ),
                );
              },
              itemCount: data.length,
          );
        },
      ),
    );
  }
}


Route _createRoute(var page2) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>  page2,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
