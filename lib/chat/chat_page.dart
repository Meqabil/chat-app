import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/chat/message_list.dart';
import 'package:professional_chat/notification/notification_service.dart';
import 'package:professional_chat/widgets/input.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChatScreen extends StatefulWidget {
  ChatScreen({
    super.key,
    required this.reciverId,
    required this.userImage,
    required this.receiverName,
    required this.myName,
    required this.myId,
    required this.myImage,
  });
  String reciverId ;
  String userImage;
  String receiverName;
  String myName;
  String myId;
  String myImage;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController message = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String? _chatRoomId;
  ScrollController scrollController = ScrollController();
  void scrollDown() {
    // Animate the scroll to the last item in the ListView
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration:const Duration(milliseconds: 300), // Animation duration
      curve: Curves.easeOut, // Animation curve
    );
  }

  /// Function to get or create a unique chat room document between two users
  Future<String> getOrCreateChatRoomId(String currentUserId, String chatUserId) async {
    final chatRoomsRef = FirebaseFirestore.instance.collection('chatRooms');

    // Query to find if there is already a chat room between these two users
    final querySnapshot = await chatRoomsRef
        .where('users', arrayContains: currentUserId)
        .get();

    // Check if any existing chat room contains both user IDs
    for (var doc in querySnapshot.docs) {
      List<dynamic> users = doc.data()['users'];
      if (users.contains(chatUserId)) {
        return doc.id; // Return existing chat room ID
      }
    }

    // If no existing chat room, create a new one
    final chatRoomRef = chatRoomsRef.doc(); // Automatically generates a unique ID
    await chatRoomRef.set({
      'users': [currentUserId, chatUserId], // List of both users in the chat
      'date': Timestamp.now(),
      'myId': widget.myId,
      'otherId':widget.reciverId,
      'otherImage': widget.userImage,
      'myName': widget.myName,
      'otherName': widget.receiverName,
      'myImage': widget.myImage,
      'lastMessage': '',
      'otherUserId': auth.currentUser!.uid == currentUserId ? chatUserId : currentUserId,
      'unreadCount': {
        currentUserId: 0,
        chatUserId: 0,
      }
    });

    return chatRoomRef.id; // Return the new chat room ID
  }

  //Intialize Room
  Future<void> _initializeChatRoom() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Get or create the chat room ID
    if (currentUserId != null) {
      _chatRoomId = await getOrCreateChatRoomId(currentUserId, widget.reciverId);
      setState(() {}); // Update UI after getting chatRoomId
    }
  }
  sendMessage(String text,String chatRoomId) async{
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': currentUserId,
      'reciverId': widget.reciverId,
      'date': Timestamp.now(),
      'isSeen': false,
    });
    //update unread messages for reciver
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .update({
      'lastMessage': text,
      'unreadCount.${widget.reciverId}': FieldValue.increment(1),
    });
  }
  String? token;
  getOtherUserToken() async{
    try{
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot data = await users.where('uid',isEqualTo: widget.reciverId).get();
      var otherUserData = data.docs.first;
      token = otherUserData['token'];
    }catch(e){
      print(e);
    }
  }
  keepMessagesSeenWhenChatOpen() async{
    setState(() {
      FirebaseFirestore.instance.collection('chatRooms').doc(_chatRoomId).update({
        'unreadCount.${FirebaseAuth.instance.currentUser!.uid}': 0,
      });
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeChatRoom();
    getOtherUserToken();

  }

  @override
  Widget build(BuildContext context) {
    if (_chatRoomId == null) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            Text(widget.receiverName,),
            const SizedBox(width: 14,),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius:const BorderRadius.all(Radius.circular(90)),
                  border: Border.all(width: 1,color: Colors.grey),
                  image: DecorationImage(
                      image: NetworkImage(widget.userImage),
                      fit: BoxFit.cover
                  )
              ),
            ),
            const SizedBox(width: 18,),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          Text(widget.receiverName,),
          const SizedBox(width: 14,),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius:const BorderRadius.all(Radius.circular(90)),
                border: Border.all(width: 1,color: Colors.grey),
                image: DecorationImage(
                    image: NetworkImage(widget.userImage),
                    fit: BoxFit.cover
                )
            ),
          ),
          const SizedBox(width: 18,),
        ],
      ),

      body: Column(
        children: [
          Expanded(child: MessagesList(chatRoomId: _chatRoomId!,scrollController: scrollController),),
          Row(
            children: [
              Expanded(child: SendInput(textEditingController: message, hint: "Send Message", hideText: false)),
              InkWell(
                child: Container(
                  alignment: Alignment.center,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    border: Border.all(width: 1,color: Colors.grey),
                    borderRadius:const BorderRadius.all(Radius.circular(90)),
                  ),
                  child: const Icon(Icons.send,color: Colors.blue,),
                ),
                onTap: (){
                  if (message.text != null && message!.text.trim().isNotEmpty) {
                    sendMessage(message.text!,_chatRoomId!);
                    NotificationService.sendNotification(
                        token!,
                        widget.receiverName,
                        message.text!,
                        widget.userImage,
                        widget.myImage,
                        widget.reciverId,
                        widget.myId,
                        widget.receiverName,
                        widget.myName,
                        _chatRoomId!,
                    );
                    scrollDown();
                    message.clear();
                  }
                },
              ),
              const SizedBox(width: 7,),
            ],
          ),
          const SizedBox(height: 10,)
        ],
      ),
    );
  }
}
  //

