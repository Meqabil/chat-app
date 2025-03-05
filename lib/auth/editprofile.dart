import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:professional_chat/dialogs/edit_password_dialoge.dart';
import 'package:professional_chat/widgets/button.dart';
import 'package:professional_chat/widgets/input.dart';
class EditProfile extends StatefulWidget {
  EditProfile({super.key,required this.docId});
  String docId;
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String image = '';
  String name = '';
  String email = '';
  String password = '';
  Future<void> getDocument(String documentId) async {
    DocumentSnapshot docSnapshot = await firestore.collection('users').doc(documentId).get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      setState(() {
        image = data['image'];
        nameController.text = data['name'];
        emailController.text = data['email'];
        passwordController.text = data['password'];
        uidController.text = data['uid'];
      });
    } else {
      print('No document found with ID: $documentId');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocument(widget.docId);
    print(email);
    //emailController.text = email;
    //passwordController.text = "password";

  }
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController uidController = TextEditingController();


  // Get Current User Information.
  FirebaseAuth auth = FirebaseAuth.instance;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Info"),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: image.isNotEmpty ?  CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(image ?? "https://firebasestorage.googleapis.com/v0/b/chat-7b2fa.appspot.com/o/av.jpg?alt=media&token=1fd284f3-0782-4ca5-ab99-d39a58d07029"),
              ) : Container(
                width: 140,
                height: 140,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.all(Radius.circular(90)),
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                child: Icon(Icons.person,color: Colors.blue,size: 85,),
              ),

            ),
            SizedBox(height: 32,),
            MyInput(textEditingController: nameController, hint: "Name", hideText: false),
            SizedBox(height: 10,),
            MyInput(textEditingController: emailController, hint: "Name", hideText: false),
            SizedBox(height: 10,),
            MyInput(textEditingController: passwordController, hint: "Name", hideText: false),
            SizedBox(height: 10,),
            MyInput(textEditingController: uidController, hint: "Name", hideText: false),
            SizedBox(height: 10,),
            MyInfoInput(
                color: Colors.grey,
                readOnly: true,
                textEditingController: passwordController,
                IC: IconButton(icon: Icon(Icons.edit),onPressed: (){
                  showDialog(context: context, builder: (context){
                    return EditPassword(email: emailController.text, password: passwordController.text);
                  });
                },),
            ),
            MyButton(text: "Save", onTap: () {}
            ),
            SizedBox(height: 20,),

          ],
        ),
      ),
    );
  }
}
