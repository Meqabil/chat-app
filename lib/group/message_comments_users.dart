import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddComment extends StatefulWidget {
  AddComment({
    super.key,
    required this.name,
    required this.image,
    required this.messageId,
    required this.groupId,
    required this.post
  });
  String image;
  String name;
  String groupId;
  String messageId;
  String post;
  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  TextEditingController text = TextEditingController();
  FirebaseAuth user = FirebaseAuth.instance;
  FirebaseFirestore users = FirebaseFirestore.instance;
  String myName = '';
  String myImage = '';
  getCurrentUserData() async{
    try{
      QuerySnapshot us = await users.collection('users').where('uid',isEqualTo: user.currentUser!.uid).get();
      var data = us.docs.first;
      setState(() {
        myName = data['name'];
        myImage = data['image'];

      });
    }catch(e){
      print(e);
    }
  }
  addComment(String comment) async{
    try{
      CollectionReference message = FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('messages').doc(widget.messageId).collection('comments');
      await message.add({
        'text': comment,
        'date':Timestamp.now(),
        'name': myName,
        'image':myImage,
        'uid': user.currentUser!.uid,
      });
    } catch(e){
      print(e);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments...'),
      ),
      body:Container(
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            Container(
              height: 200,

              width: double.infinity,
              padding: EdgeInsets.all(8),
              color:Theme.of(context).colorScheme.secondary,
              child:SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(

                          radius: 30,
                          backgroundImage: NetworkImage(
                            widget.image
                          ),
                        ),
                        SizedBox(width: 12,),
                        Text('${widget.name}',style: TextStyle(fontSize: 21,color: Colors.green),)
                      ],
                    ),
                    SizedBox(height: 15,),
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('${widget.post}',style: TextStyle(fontSize: 17),),
                    )
                  ],
                ),
              ),
            ),
             Divider(),
             const SizedBox(height: 19,),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('messages').doc(widget.messageId).collection('comments').snapshots(),
                  builder:(context, AsyncSnapshot<QuerySnapshot> snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var comments = snapshot.data!.docs;
                    return ListView.builder(
                      itemBuilder: (context,i){
                        return Container(
                          margin: EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(
                                  comments[i]['image'],
                                ),
                              ),
                              SizedBox(width: 10,),
                              Container(
                                width: MediaQuery.of(context).size.width - 100,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: Theme.of(context).colorScheme.background,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${comments[i]['name']}',style: TextStyle(fontSize: 20),),
                                    Text('  ${comments[i]['text']}',style: TextStyle(fontSize: 17),),
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ((comments[i]['date']as Timestamp).toDate().hour != DateTime.now().hour) ? Text(
                                            (comments[i]['date'] as Timestamp).toDate().hour.toString(),
                                            style: TextStyle(color: Colors.white, fontSize: 14),
                                          ) : Text(""),
                                          Text(":"),
                                          Text(
                                            (comments[i]['date'] as Timestamp).toDate().minute.toString(),
                                            style: TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                          Text(" ",style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text(
                                            (comments[i]['date'] as Timestamp).toDate().day.toString(),
                                            style: TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                          Text("-",style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text(
                                            (comments[i]['date'] as Timestamp).toDate().month.toString(),
                                            style: TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                          Text("-",style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text(
                                            (comments[i]['date'] as Timestamp).toDate().year.toString(),
                                            style: TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: comments.length,
                    );
                  },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inversePrimary, // Light grey background for the input
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        controller: text,
                        maxLines: 3, // This makes the input expandable
                        minLines: 1,
                        decoration: InputDecoration(

                          border: InputBorder.none,
                          hintText: 'Type a comment... ',
                          hintStyle: TextStyle(
                            color: Colors.green,
                          )
                        ),
                      ),
                    ),
                  ),
                  IconButton(onPressed: (){
                    if(text.text.isNotEmpty){
                      addComment(text.text);
                      text.clear();
                    }
                  }, icon: Icon(Icons.send,color: text.text == '' ? Colors.grey : Colors.green,))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
