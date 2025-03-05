import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat/chat_page.dart';

class DataSearch extends SearchDelegate<String>{
  DataSearch({
    required this.userList,
    required this.myName,
    required this.myImage,
  });
  final List userList;
  final String myName;
  final String myImage;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(onPressed: (){
      query = '';

    }, icon: Icon(Icons.close))];
  }
  @override
  Widget buildLeading(BuildContext context){
    return IconButton(onPressed: (){
      close(context, 'hello');

    }, icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context){
    return Text('data');
  }
  @override
  Widget buildSuggestions(BuildContext context){
    List filterNames = userList.where((element) {
      final String name = element['name'].toString().toLowerCase();
      final String searchQuery = query.toLowerCase();
      return name.contains(searchQuery);
    }).toList();
    return ListView(
      children: filterNames.map((doc) {
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
  }

}