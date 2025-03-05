import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/customsearch/v1.dart';
import 'package:professional_chat/chat/chat_page.dart';
import 'package:professional_chat/user_Search.dart';
import 'package:professional_chat/widgets/mydrawer.dart';
import 'package:badges/badges.dart' as badges;

List usersData = [];
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  userState(){
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("signup");
      }
    });
  }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userState();
    getCurrentUserData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home",style: TextStyle(color:Colors.blue),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            showSearch(context: context, delegate: DataSearch(
                userList: usersData,
                myImage: myImage,
                myName: myName,
            ));
          }, icon: Icon(Icons.search))
        ],
      ),
      body: StreamBuilder(
        builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          usersData = snapshot.data!.docs;
          return ListView(
              children: snapshot.data!.docs.map((doc){
                return Card(
                  child: ListTile(
                    leading: Container(
                      alignment: Alignment.center,
                      padding:const EdgeInsets.all(0),
                      width: 55,
                      height: 55,
                      child: {doc['image']}.isNotEmpty ? CircleAvatar(
                        backgroundImage: NetworkImage("${doc['image']}"),
                        radius: 45,
                      ) : Icon(Icons.account_circle_sharp,color: Colors.blue,size: 50,),
                      decoration: BoxDecoration(
                        borderRadius:const BorderRadius.all(Radius.circular(90)),
                        color: Colors.lightGreen,
                        border: Border.all(width: 1,color: Colors.grey)
                      ),
                    ),
                    title: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              child: Text("${doc['name']}",style: TextStyle(color: Colors.green,fontSize: 18,),),
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                          ),
                          Container(
                              child: Text("${doc['email']}"),
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                          ),
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ChatScreen(
                            reciverId: doc['uid'],
                            userImage: doc['image'],
                            receiverName: doc['name'],
                            myId: FirebaseAuth.instance.currentUser!.uid,
                            myImage: myImage,
                            myName: myName,
                          ),
                          )
                      );
                    },
                  ),
                );
              }).toList(),
              
          );
        },
        stream: FirebaseFirestore.instance.collection("users").where('uid',isNotEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
      ),
    );
  }
}




