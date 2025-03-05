import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/group/group_bubble.dart';
import 'package:professional_chat/group/group_info.dart';
class GroupChatPage extends StatelessWidget {
  final String groupId;
  final String currentUserId;
  final String groupName;
  final String groupImage;
  final String groupAdmin;
  final int nthOfMembers;
  List members;
  GroupChatPage({
    required this.groupId,
    required this.nthOfMembers,
    required this.currentUserId,
    required this.groupName,
    required this.groupImage,
    required this.groupAdmin,
    required this.members,
  });
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth user = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${groupName}"),
        actions: [
          SizedBox(width: 13,),
          Hero(
              tag: 'profile-tag',
              child: InkWell(
                child: Image.network(groupImage,width: 120,fit: BoxFit.cover,),
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return GroupInfo(
                      groupName: groupName,
                      groupImage: groupImage,
                      adminId: groupAdmin,
                      nthOfMembers: nthOfMembers,
                      members: members,
                      groupId: groupId,
                    );
                  },));
                },
              )
          ),
          SizedBox(height: 10,),
        ],
      ),
      body: Column(
        children: [
          // Display messages in the group
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chatDocs = chatSnapshot.data!.docs;
                return ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    return GroupBubble(
                        message: chatDocs[index]['text'],
                        isMe: chatDocs[index]['senderId'] == user.currentUser!.uid,
                        likes: chatDocs[index]['likes'].length,
                        comments: 0,
                        userName: chatDocs[index]['senderName'],
                        userId: chatDocs[index]['senderId'],
                        userImage: chatDocs[index]['image'],
                        groupId: groupId,
                        messageId: chatDocs[index].id,
                    );
                  },
                );
              },
            ),
          ),
          // Message input
          MessageInput(
            groupId: groupId,
            groupMembers: members,
            currentUserId: currentUserId,
          ),
        ],
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final String groupId;
  final String currentUserId;
  List groupMembers;

  MessageInput({required this.groupId, required this.currentUserId,required this.groupMembers});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool canSendMessage = false;
  bool isMentioning = false;
  List mentionSuggestions = [];
  List groupMembers = [];

  // Check if the current user is a member of the group
  Future<void> _checkUserPermissions() async {
    DocumentSnapshot groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();
    List<dynamic> members = groupDoc['members'];
    setState(() {
      canSendMessage = members.contains(widget.currentUserId);
    });
  }
  Future<String?> getUserImageBasedOnId(String uid) async{
    try{
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      QuerySnapshot id = await users.where('uid',isEqualTo: uid).get();
      if(id.docs.isNotEmpty){
        var image = id.docs.first;
        return image['image'];
      } else{
        print('no user found');
        return null;
      }
    }catch (e){
      return null;
    }
  }
  Future<String?> getUserNameBasedOnId(String uid) async{
    try{
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot id = await users.where('uid' ,isEqualTo: uid).get();
      var name;
      if(id.docs.isNotEmpty){
        name = id.docs.first;
        return name['name'];
      } else{
        return null;
      }
    }catch(e){
      return null;
    }
  }
  Future<String?> getUserIdBasedOnId() async{
    try{
      FirebaseAuth user = FirebaseAuth.instance;
      QuerySnapshot uid = await firestore.collection('users').where('uid',isEqualTo: user.currentUser!.uid).get();
      var id;
      if(uid.docs.isNotEmpty){
        id = uid.docs.first;
      } else{
        id = user.currentUser!.uid;
        return id['senderId'];
      }
    }catch(e){
      return null;
    }
    return null;
  }
  void _sendMessage() async {
    FirebaseAuth user = FirebaseAuth.instance;
    //String? ud = await getUserIdBasedOnId();
    String? userImage = await getUserImageBasedOnId(user.currentUser!.uid);
    String? userName = await getUserNameBasedOnId(user.currentUser!.uid);
    if (_controller.text.trim().isEmpty || !canSendMessage) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'text': _controller.text,
      'senderId': widget.currentUserId,
      'image': userImage,
      'senderName': userName,
      'timestamp': Timestamp.now(),
      'likes' : [],
    });

    _controller.clear();
  }
  bool amIMember = false;
  getGroupIdMembers() async{
    try{
      CollectionReference groups = FirebaseFirestore.instance.collection('groups');
      var data = await groups.doc(widget.groupId).get();
      var groupData = data.data();
      if (groupData != null && groupData is Map<String, dynamic>) {
        // Access 'members' only if `groupData` contains it
        List members = groupData['members'] ?? [];
        if(members.contains(widget.currentUserId)){
          amIMember = true;
        }
      }
    } catch (e){
      print(e);
    }
  }


  void setTextInputForMention(){
    _controller.addListener(() {
      String text = _controller.text;
      if (text.contains('@')) {
        int atIndex = text.lastIndexOf('@');
        String mentionQuery = text.substring(atIndex + 1);
        setState(() {
          isMentioning = mentionQuery.isNotEmpty;
          mentionSuggestions = groupMembers
              .where((member) =>
              member['name'].toLowerCase().contains(mentionQuery.toLowerCase()))
              .map((member) => member['name'])
              .toList();
        });
      } else {
        setState(() {
          isMentioning = false;
          mentionSuggestions = [];
        });
      }
    });
  }
  @override
  void initState() {
    super.initState();
    groupMembers = widget.groupMembers;
    getGroupIdMembers();
    _checkUserPermissions();
    setTextInputForMention();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end ,
            children: [
              Expanded(
                //Here are you member
                child: amIMember ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary, // Light grey background for the input
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    controller: _controller,
                    decoration:const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.deepPurple) ,
                      border: InputBorder.none,
                    ),
                    maxLines: 3, // This makes the input expandable
                    minLines: 1,
                  ),
                ) : Center(
                  child: Text("Only Members Are permitted"),
                ),
              ),
              amIMember ? IconButton(
                icon: Icon(Icons.send),
                onPressed: canSendMessage ? _sendMessage : null, // Disable button if not allowed
              ): Text(''),
            ],
          ),
        ],
      ),
    );
  }
}


