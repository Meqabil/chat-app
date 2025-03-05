import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/group/message_comments_users.dart';

class GroupBubble extends StatefulWidget {
  GroupBubble({super.key,required this.message,required this.messageId,required this.isMe,required this.groupId,required this.likes,required this.userId,required this.comments,required this.userName,required this.userImage});
  String message;
  bool isMe;
  int likes;
  int comments;
  String userName;
  String userImage;
  String userId;
  String groupId;
  String messageId;
  @override
  State<GroupBubble> createState() => _GroupBubbleState();
}


class _GroupBubbleState extends State<GroupBubble> {
  List currentlyLikedUser = [];
  int commentsNumber = 0;
  int likesCount = 0;
  bool hasLiked = false;
  Future<List?> getUserLikedList () async{
    try{
      var likedUsers = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('messages').doc(widget.messageId).get();
      var list = likedUsers.data();
      List l = await list?['list'];
      if(list!.isNotEmpty){
        currentlyLikedUser = l;
        return l;
      }else{
        return [];
      }
    }catch(e){
      return [];
    }
  }
  Future<void> _getLikesCount() async {
    DocumentSnapshot messageDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc(widget.messageId)
        .get();

    setState(() {
      likesCount = (messageDoc['likes'] as List?)?.length ?? 0;
      hasLiked = (messageDoc['likes'] as List?)?.contains(FirebaseAuth.instance.currentUser!.uid) ?? false;
    });
  }
  Future<int?> getCommentsNumber() async{
    try{
      CollectionReference message = FirebaseFirestore.instance
          .collection('groups').doc(widget.groupId)
          .collection('messages')
          .doc(widget.messageId).collection('comments');
      QuerySnapshot s = await message.get();
      int data = s.docs.length;
      setState(() {
        commentsNumber = data;
        print(commentsNumber);
      });
      return data;
    }catch (e){
      print(e);
    }
  }
  toggleLikes() async{
    try{
      CollectionReference messages = FirebaseFirestore.instance.collection('groups');
      final messageRef =  messages.doc(widget.groupId).collection('messages').doc(widget.messageId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(messageRef);
        List LikesList = snapshot['likes'] ?? [];
        if(LikesList.contains(auth.currentUser!.uid)){
          transaction.update(messageRef, {
            'likes': FieldValue.arrayRemove([auth.currentUser!.uid]),
          });
          snapshot['likes'].length --;
          setState(() {
            likesCount--;
            hasLiked = false;
          });
        }else{
          transaction.update(messageRef, {
            'likes':FieldValue.arrayUnion([auth.currentUser!.uid]),
          });
          snapshot['likes'].length ++;
          setState(() {
            likesCount++;
            hasLiked = true;
          });
        }
      });
    }catch (e){
      print(e);
    }
  }
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLikesCount();
    getCommentsNumber();
  }
  @override
  Widget build(BuildContext context) {
    // Highlight mentions in the message text
    final highlightedMessage = widget.message.split(' ').map((word) {
      if (word.startsWith('@')) {
        return TextSpan(
          text: word + ' ',
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.bold),
        );
      } else {
        return TextSpan(text: word + ' ', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary));
      }
    }).toList();
    return widget.isMe ? Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 270,
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(14),bottomLeft: Radius.circular(14),bottomRight: Radius.circular(14)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${widget.userName}',style: TextStyle(color: Colors.green),),
              Container(
                  padding: EdgeInsets.all(10),
                  child: RichText(
                    text: TextSpan(
                      children: highlightedMessage,
                      style: TextStyle(
                        fontSize: 16,
                      )
                    ),
                  ),
              ),
              Divider(color: Colors.grey.shade300,height: 1,endIndent: 50,indent: 50,),
              Row(
                children: [
                  InkWell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(onPressed: (){
                          toggleLikes();
                        }, icon: Icon(Icons.thumb_up,color: hasLiked ? Colors.blue: Colors.grey )),
                        Text('${widget.likes}'),
                      ],
                    ),
                  ),
                  InkWell(
                    child: Row(
                      children: [
                        IconButton(onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return AddComment(
                                name: widget.userName,
                                image: widget.userImage,
                                messageId: widget.messageId,
                                groupId: widget.groupId,
                                post: widget.message,
                            );
                          },));
                        }, icon: Icon(Icons.comment,color: Colors.grey,)),
                        Text('${widget.comments}'),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              )
            ],
          ),
        ),
        SizedBox(width: 10,),
      ],
    ) : Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 4,),
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
              '${widget.userImage}'
          ),
        ),
        SizedBox(width: 6,),
        Container(
          width: 270,
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(topRight: Radius.circular(14),bottomLeft: Radius.circular(14),bottomRight: Radius.circular(14)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.userName}',style: TextStyle(color: Colors.blue),),
              Container(
                  padding: EdgeInsets.all(10),
                  child: RichText(
                    text: TextSpan(
                        children: highlightedMessage,
                        style: TextStyle(
                          fontSize: 16,
                        )
                    ),
                  ),
              ),
              Divider(color: Colors.purple,height: 1,endIndent: 50,indent: 50,),
              Row(
                children: [
                  InkWell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(onPressed: (){
                          toggleLikes();
                        }, icon: Icon(Icons.thumb_up,color: hasLiked ? Colors.blue: Colors.grey.shade200)),
                        Text('${widget.likes}',style: const TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                  InkWell(
                    child: Row(
                      children: [
                        IconButton(onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return AddComment(
                              name: widget.userName,
                              image: widget.userImage,
                              messageId: widget.messageId,
                              groupId: widget.groupId,
                              post: widget.message,
                            );
                          },));
                        }, icon: Icon(Icons.comment,color: Colors.grey.shade200,)),
                        Text('${commentsNumber}',style: const TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
