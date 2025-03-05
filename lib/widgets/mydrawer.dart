import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:professional_chat/auth/editprofile.dart';
import 'package:professional_chat/notification/notify.dart';
class MyDrawer extends StatefulWidget {
  MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}
class _MyDrawerState extends State<MyDrawer> {
  String name = '';
  String email = '';
  String image = '';
  String id = '';
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference firestore = FirebaseFirestore.instance.collection("users");
  DocumentSnapshot? userDocument;

  getMyId()async{
    try{
      CollectionReference groups = FirebaseFirestore.instance.collection('users');
      QuerySnapshot data = await groups.where('uid',isEqualTo: currentUser).get();
      if(data.docs.isNotEmpty){
        id = data.docs.first.id;
        print("ID:               ${id}           +++++++==========");
      }
    }catch(e){
      print(e);
    }
  }
  Future<void> getDocument() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    if(auth.currentUser!.uid != null){
      try{
        QuerySnapshot querySnapshot = await firestore.where('uid' ,isEqualTo: auth.currentUser!.uid).get();
        if(querySnapshot.docs.isNotEmpty){
          userDocument = querySnapshot.docs.first;
          String documentId = userDocument!.id;
          DocumentSnapshot documentSnapshot = await firestore.doc(documentId).get();
          if(documentSnapshot.exists){
            Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
            setState(() {
              name = data['name'];
              email = data['email'];
              image = data['image'];
            });
          }
        } else{
          print("No Document Found .");
        }
      } catch (e){
        print("Error fetch document : $e ");
      }
      setState(() {

      });
    }
    else{
      print("No user found");
    }
  }
  logOut() async {
    await FirebaseAuth.instance.signOut();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocument();
    getMyId();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            accountName: Text("${name}"),
            accountEmail: Container(
                height: 20,
                child: Row(
                  children: [
                    Text("${email}"),
                    Spacer(),
                    IconButton(onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        String sd = id;
                        return EditProfile(docId: sd);
                      }));
                    }, icon: Icon(Icons.edit,size: 17,))
                  ],
                )
            ),
            currentAccountPicture:Container(
              child: image.isNotEmpty ? CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(image)
              ) : Container(
                  width: 90,
                  height: 90,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.all(Radius.circular(90)),
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: Icon(Icons.person,size: 65,color: Colors.white,)
              ),
            ) ,
          ),
          Container(
            padding: EdgeInsets.all(2),
            child: ListTile(
              title: Text("Show Users Info (only admin)"),
              trailing: Icon(Icons.people),
              onTap: (){
                Navigator.of(context).pushNamed("userlist");
              },

            ),
          ),
          Container(
            padding: EdgeInsets.all(2),
            child: ListTile(
              title: Text("Your Groups"),
              trailing: Icon(Icons.people),
              onTap: (){
                Navigator.of(context).pushNamed("yourgroups");
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(2),
            child: ListTile(
              title: Text(" Log Out"),
              trailing: Icon(Icons.logout),
              onTap: (){
                logOut();
                Navigator.of(context).pushReplacementNamed("login");
              },
            ),
          ),
        ],
      ),
    );
  }
}
