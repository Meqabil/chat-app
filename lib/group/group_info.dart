import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:professional_chat/group/addNewMembrs.dart';

class GroupInfo extends StatefulWidget {
  final String groupName;
  final String groupImage;
  final int nthOfMembers;
  final String adminId;
  final String groupId;
  List members ;

  GroupInfo({
    Key? key,
    required this.groupName,
    required this.groupImage,
    required this.nthOfMembers,
    required this.adminId,
    required this.members,
    required this.groupId,
  }) : super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}
FirebaseFirestore firestore = FirebaseFirestore.instance;
class _GroupInfoState extends State<GroupInfo> {
  Future<List<Map<String,dynamic>>> getData() async{
    CollectionReference membersOfGroup =  firestore.collection('users');
    try{
      QuerySnapshot querySnapshot = await membersOfGroup.get();
      List<Map<String,dynamic>> usersList = [];
      querySnapshot.docs.forEach((element) {
        Map<String,dynamic> userData = element.data() as Map<String,dynamic>;
        usersList.add(userData);
      });
      return usersList;
    } catch (e){
      print('Error fetching data: $e');
      return [];
    }
  }
  List<Map<String,dynamic>> users = [];
  void retriveData()async{
    users = await getData();
    for(var user in users){
      print('${user['name']}');
      print('${users[3]['uid']}');
    }
  }

  Future<String?> getImageById(String uid) async{
    try{
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot data = await users.where('uid',isEqualTo: uid).get();
      var memberData;
      String id;
      if(data.docs.isNotEmpty){
        memberData = data.docs.first;
        id = memberData['image'];
        return id;
      }
    }catch (e){
      print(e);
    }
    return '';
  }

  Future<String?> getNameById(String uid) async{
    try{
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot data = await users.where('uid',isEqualTo: uid).get();
      var memberData;
      String id;
      if(data.docs.isNotEmpty){
        memberData = data.docs.first;
        id = memberData['name'];
        return id;
      }
    }catch (e){
      print(e);
    }
    return '';
  }
  List groupMembers = [];
  @override
  void initState() {
    super.initState();
    getData();
    retriveData();
    groupMembers = widget.members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Page"),
      ),
      floatingActionButton: widget.adminId != FirebaseAuth.instance.currentUser!.uid ? null :
      FloatingActionButton.small(

        onPressed: () async{
          //add new members
          List newMembers = await showDialog(
              context: context,
              builder: (context){
                  return AddNewMembers(members: groupMembers,groupId: widget.groupId,);
          });

          //Check if there are elements are added
          if(newMembers != null && newMembers.isNotEmpty){
            setState(() {
              groupMembers.addAll(newMembers.where((uid) => !groupMembers.contains(uid)));
            });
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ) ,
      body: Container(
        padding: EdgeInsets.all(8),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  border: Border.all(width: 1,color:Colors.blue),
                  borderRadius: const BorderRadius.all(Radius.circular(12))
              ),
              child: Hero(
                child: Image.network(
                  widget.groupImage,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                ),
                tag: 'profile-tag',
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 60,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  border: Border.all(width: 1,color:Colors.blue),
                  borderRadius: const BorderRadius.all(Radius.circular(12))
              ),
              child: Row(
                children: [
                  SizedBox(width: 12,),
                  Text('Group Name : '),
                  Text(widget.groupName)
                ],
              ),
            ),
            Container(
                width: double.infinity,
                height: 60,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border.all(width: 1,color:Colors.blue),
                    borderRadius: const BorderRadius.all(Radius.circular(12))
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12,),
                    Text('Number of members : '),
                    Text('${widget.nthOfMembers} Members'),
                  ],
                )
            ),
            Expanded(
              child: StreamBuilder(
                stream: firestore.collection('users').where('uid',whereIn: groupMembers).snapshots(),
                builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
                  var data = snapshot.data!.docs;
                  return ListView.builder(
                    itemBuilder: (context, i) {
                      return widget.adminId == data[i]['uid'] ? Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              border: Border.all(width: 1,color: Colors.purple)
                          ),
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.all(2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              data[i]['image'].isNotEmpty ? CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 25,
                                backgroundImage: NetworkImage(
                                  data[i]['image'],
                                ),
                              ) : Icon(Icons.person, size: 60,),
                              SizedBox(width: 15,),
                              Text('${data[i]['name']}'),
                              Spacer(flex: 1),
                              Text('Admin',style: TextStyle(color:Colors.blue),),
                              SizedBox(width: 15,)
                            ],
                          )
                      )
                          : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(width: 1,color: Colors.green)
                        ),
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            data[i]['image'].isNotEmpty ? CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 25,
                              backgroundImage: NetworkImage(
                                data[i]['image'],
                              ),
                            ) : Icon(Icons.person,size: 60,),
                            SizedBox(width: 15,),
                            Text('${data[i]['name']}'),
                            Spacer(flex: 1,),
                            IconButton(onPressed: () async{
                              await showMyBottomSheet(context,
                                  data[i]['name'],
                                  data[i]['image'],
                                  data[i]['uid'],
                                  data[i]['email'],
                                  widget.adminId == FirebaseAuth.instance.currentUser!.uid,
                                  widget.groupId,
                                  i,
                              );
                            }, icon: Icon(Icons.more_vert))
                          ],
                        ) ,
                      );
                    },
                    itemCount: data.length, // Total members in the list
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


showMyBottomSheet(context,String name,String image,String id,String email,bool isAdmin,String groupId,int index){
  showModalBottomSheet(context: context,
    builder: (context) {
      return Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height / 3 + 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(image),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text('Name : ',style:TextStyle(color: Colors.lightGreen),),
                  Text(name),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text('Email : ',style:TextStyle(color: Colors.lightGreen),),
                  Text(email),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text('ID : ',style:TextStyle(color: Colors.lightGreen),),
                  Text(id),
                ],
              ),
            ),
            isAdmin ?Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: InkWell(
                child: Row(
                  children: [
                    Text('Delete this user',style:TextStyle(color: Colors.white),),
                    Spacer(),
                    Icon(Icons.delete,color: Colors.white,)
                  ],
                ),
                onTap: () async{
                  await deleteUserByAdmin(context,id, groupId);
                  Navigator.of(context).pushNamedAndRemoveUntil("chatrooms", (route) => false);
                },
              ),
            ) : Text(''),
          ],
        ),
      );
    },
  );
}


deleteUserByAdmin(context,String id,String groupId) async{
  try{
    CollectionReference groups = FirebaseFirestore.instance.collection('groups');
    DocumentSnapshot myGroup = await groups.doc(groupId).get();
    var data;
    if(myGroup.exists){
      data = myGroup.data();
      List members = data['members'];
      members.remove(id);
      await groups.doc(groupId).update({
        'members': members,
      });
    }
  }catch(e){
    print(e);
  }

}

