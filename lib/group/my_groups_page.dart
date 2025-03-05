import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:professional_chat/group/group_chat_page.dart';

import '../dialogs/group_page_dialoge.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key,});
  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.people),
        onPressed: (){
          showDialog(context: context, builder: (context) {
            return CreateGroupPage();
          },);
      }, label: Text('Create Group')),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
           SizedBox(height: 10,),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final yourGroups = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: yourGroups.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        child: ListTile(
                          leading: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(0),
                            width: 75,
                            height: 50,
                            color: Colors.purple,
                            child: yourGroups[index]['groupCover'] != 'empty'  && (yourGroups[index]['groupCover'] != null)
                                ? Image.network(yourGroups[index]['groupCover'],fit: BoxFit.fitWidth,width: double.infinity,)
                                : Image.asset('assets/group_cover.png',fit: BoxFit.cover,width: double.infinity,),
                          ),
                          title: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                              children: [
                                Container(
                                  child: Text(
                                    yourGroups[index]['groupName'],
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                    ),
                                  ),
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                ),
                                Container(
                                  child: Text('${yourGroups[index]['members'].length} Members.'),
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(icon:Icon(Icons.more_vert,),onPressed: (){
                            showMyBottomSheet(context,
                                yourGroups[index].id,
                            );
                          },),
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) =>
                                    GroupChatPage(
                                        groupId: yourGroups[index].id,
                                        currentUserId:FirebaseAuth.instance.currentUser!.uid,
                                        groupName: yourGroups[index]['groupName'],
                                        groupImage: yourGroups[index]['groupCover'],
                                        groupAdmin: yourGroups[index]['adminId'],
                                        nthOfMembers: yourGroups[index]['members'].length,
                                        members: yourGroups[index]['members'],
                                    ),
                                )
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



showMyBottomSheet(context,
    String groupId,
){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context,){
        return Container(
          height: 200,
          width: MediaQuery.sizeOf(context).width,
          color: Colors.white,
          child: Column(
            children: [
              Text('group link : '),
              IconButton(onPressed: (){
                generateGroupLink(
                  groupId: groupId,
                );

                print('Your group Link Is : $link .');
                // Text to copy
                Clipboard.setData(ClipboardData(text: link)); // Copy text to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Text copied to clipboard')),
                );
              }, icon: Icon(Icons.copy,color: Colors.grey,size: 35,)),
            ],
          ),
        );
      }
  );
}


String link = '';
Future<String?> generateGroupLink({
  required String groupId,
}) async{

  final DynamicLinkParameters parameters = DynamicLinkParameters(
      link: Uri.parse('https://yourapp.page.link/group?groupId=$groupId'),
      uriPrefix: 'https://professionalchatmeqabil.page.link',
      androidParameters: AndroidParameters(
        packageName: 'com.example.chat_app',
        minimumVersion: 1
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.example.chat_app',
        minimumVersion: '1.0.0',
      ),
  );
  final Uri shortLink = await FirebaseDynamicLinks.instance.buildLink(parameters);
  print("================================================= ${shortLink.toString()}");
  link = await shortLink.toString();
  return shortLink.toString();
}