import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/auth/editprofile.dart';

class ListUsersPage extends StatefulWidget {
  const ListUsersPage({super.key});

  @override
  State<ListUsersPage> createState() => _ListUsersPageState();
}

class _ListUsersPageState extends State<ListUsersPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Of Users",style: TextStyle(color:Colors.blue),),
        centerTitle: true,
      ),
      body: StreamBuilder(
        builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((doc){
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(0),
                    width: 55,
                    height: 55,
                    child: Container(
                      width: 55,
                      height: 55,
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.all(Radius.circular(90)),
                          border: Border.all(width: 1,color: Colors.grey),
                          image: DecorationImage(
                            image: NetworkImage("${doc['image']}"),
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(90)),
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
                    print(doc.id);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfile(docId: doc.id),));
                  },
                ),
              );
            }).toList(),

          );
        },
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
      ),
    );
  }
}
