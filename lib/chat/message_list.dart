import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bubble_message.dart';

class MessagesList extends StatefulWidget {
  final String chatRoomId;

  MessagesList({required this.chatRoomId,required this.scrollController});
  ScrollController scrollController = ScrollController(); // ScrollController added

  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  void scrollDown(){
  ScrollController scrollController = widget.scrollController;
    scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.bounceIn
    );
  }

  @override
  void dispose() {
    ScrollController scrollController = widget.scrollController;
    scrollController.dispose(); // Dispose the controller when no longer needed
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markMessageAsSeen(widget.chatRoomId!);
    });
  }

  void markMessageAsSeen(String chatRoom) async{
    final currentUser = FirebaseAuth.instance.currentUser;
    QuerySnapshot messages = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoom)
        .collection('messages')
        .where('reciverId',isEqualTo: currentUser!.uid)
        .get();
    for(var doc in messages.docs){
      await doc.reference.update({'isSeen':true});
    }

    // Reset the unread messages for the current user
    FirebaseFirestore.instance.collection('chatRooms').doc(widget.chatRoomId).update({
      'unreadCount.${FirebaseAuth.instance.currentUser!.uid}': 0,
    });

  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .orderBy('date', descending: false,)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final chatDocs = chatSnapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;

        return ListView.builder(
          controller: widget.scrollController, // Attach ScrollController here
          reverse: false,
          itemCount: chatDocs.length, // No need for null check, List length is available
          itemBuilder: (ctx, index) {
            final isSameUserAsNext = index < chatDocs.length - 1 &&
                chatDocs[index]['senderId'] == chatDocs[index + 1]['senderId'];
            final isSameUserAsPrevious = index > 0 &&
                chatDocs[index]['senderId'] == chatDocs[index - 1]['senderId'];

            // Use MessageBubble2 for consecutive bubbles from the same user except the last one
            if (isSameUserAsNext) {
              return MessageBubble2(
                message: chatDocs[index]['text'],
                isMe: chatDocs[index]['senderId'] == currentUserId,
                isSeen: chatDocs[index]['isSeen'],
              );
            } else if (isSameUserAsPrevious && !isSameUserAsNext) {
              // Use MessageBubble for the last message of a group
              return MessageBubble(
                message: chatDocs[index]['text'],
                isMe: chatDocs[index]['senderId'] == currentUserId,
                isSeen: chatDocs[index]['isSeen']
              );
            } else {
              // If it's a standalone message, use MessageBubble
              return MessageBubble(
                message: chatDocs[index]['text'],
                isMe: chatDocs[index]['senderId'] == currentUserId,
                isSeen: chatDocs[index]['isSeen'],
              );
            }
          },
        );
      },
    );
  }
}
