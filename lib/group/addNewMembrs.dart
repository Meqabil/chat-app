import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/main.dart';

class AddNewMembers extends StatefulWidget {
  const AddNewMembers({super.key,required this.members,required this.groupId});
  final List members;
  final String groupId;
  @override
  State<AddNewMembers> createState() => _AddNewMembersState();

}

class _AddNewMembersState extends State<AddNewMembers> {
  List selectedUsers = [];
  List currentMembers = [];
  @override
  void initState() {
    // TODO: implement initState
    selectedUsers = widget.members;
    print(currentMembers);
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('users').where('uid',whereNotIn: selectedUsers).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length//widget.users.length,
                      ,itemBuilder:(ctx, index) {
                      return CheckboxListTile(
                        secondary: CircleAvatar(
                          backgroundImage: NetworkImage(
                              users[index]['image']
                          ),
                        ),
                        enabled: !widget.members.contains(users[index]['uid']),
                        title: Text(users[index]['name']),
                        value: currentMembers.contains(users[index]['uid']) ,
                        activeColor: Colors.blue,
                        onChanged: (isChecked) {
                          setState(() {
                            if (isChecked == true) {
                              currentMembers.add(users[index]['uid']);
                              print(selectedUsers);
                            } else {
                              currentMembers.remove(users[index]['uid']);
                            }
                          });
                        },
                      );
                    },
                    );
                  },
                )
            ),
            ElevatedButton(
              child: Text("add ${currentMembers.length} Members "),
              onPressed: () {
                addNumOfUsersToGroup(currentMembers, widget.groupId);
                Navigator.of(context).pop(currentMembers);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: Size(double.maxFinite, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

addNumOfUsersToGroup(List users,String groupId) async{
  try{
    print(users);
    CollectionReference groups = FirebaseFirestore.instance.collection('groups');
    DocumentSnapshot data = await groups.doc(groupId).get();
    var groupData;
    List members;
    if(data.exists){
      groupData = data.data();
      members = groupData['members'];
      members.addAll(users);
      print(members);
      addThem(groupId, members);
    }
  } catch(e){
    print(e);
  }
}

addThem(String groupId,List members) async{
  try{

    print("List : ============================ ${members} ========== ");
    CollectionReference groups = FirebaseFirestore.instance.collection('groups');
    await groups.doc(groupId).update({
      'members': members,
    });
    print('Added successfully..');
  }catch(e){
    print(e);
  }
}
