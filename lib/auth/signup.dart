import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:professional_chat/widgets/button.dart';
import 'package:professional_chat/widgets/input.dart';

import '../dialogs/upload_profile_image.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  FirebaseAuth user = FirebaseAuth.instance;
  Future signWithEmailandPassword(context) async{
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      String? imageUrl = _image != null ? await uploadImageToFirebase(context,_image!) : "https://firebasestorage.googleapis.com/v0/b/chat-7b2fa.appspot.com/o/av.jpg?alt=media&token=1fd284f3-0782-4ca5-ab99-d39a58d07029";
      addUser(imageUrl);
      //_image == null ? addUser("https://firebasestorage.googleapis.com/v0/b/chat-7b2fa.appspot.com/o/av.jpg?alt=media&token=1fd284f3-0782-4ca5-ab99-d39a58d07029"):print('failed to upload .');
      Navigator.of(context).pushReplacementNamed("chatrooms");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        showSnackBar(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        showSnackBar(context, "The account already exists for that email.");
      }
    } catch (e) {
      print(e);
      showSnackBar(context, '$e');
    };
  }
 Future <String?> uploadImageToFirebase(BuildContext context,File image) async {
    try {
      // Create a storage reference
      String fileName = basename(image.path); // Extract file name
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = firebaseStorageRef.putFile(image);

      // Monitor the upload progress
      showDialog(
        context: context,
        barrierDismissible: false, // Prevents dismissing the dialog while uploading
        builder: (BuildContext context) {
          return UploadProgressDialog(uploadTask: uploadTask);
        },
      );

      // Get the download URL once the upload is complete
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      print('File uploaded successfully. Download URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      print('Error occurred while uploading image: $e');
    }
  }
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? tocken;
  getTocken() async{
    tocken = await messaging.getToken();
  }
  Future addUser(var image) async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection("users");
    collectionReference.add({
      "uid": user.currentUser!.uid,
      "name": name.text,
      "email": email.text,
      "password": password.text,
      "image": image,
      'token':tocken,
    });
  }

  File? _image;  // To store the picked image
  final _picker = ImagePicker();  // ImagePicker instance

  // Function to pick an image from gallery or camera
  _pickImage() async {
    var pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);  // Store the image file
      });
    } else {
      print('No image selected.');
    }
  }

  showSnackBar(BuildContext context,String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message),backgroundColor: Colors.red,)
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTocken();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up",style: TextStyle(color: Colors.blue),),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 12,),
          InkWell(
            child: _image == null ? CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage(
                  "assets/avatar.png",
              ),
            ) :
            CircleAvatar(
              backgroundImage: FileImage(_image!),
              radius: 45,
            )  ,
            onTap: _pickImage,
          ),
          SizedBox(height: 42,),
          MyInput(
            textEditingController: name,
            hint: "Name",
            hideText: false,
          ),

          SizedBox(height: 12,),
          MyInput(
            textEditingController: email,
            hint: "Email",
            hideText: false,
          ),
          SizedBox(height: 12,),
          MyInput(
            textEditingController: password,
            hint: "Password",
            hideText: true,
          ),
          SizedBox(height: 12,),
          MyButton(
              text: "Sign Up",
              onTap: () {
                signWithEmailandPassword(context);
              }
          ),
          Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children:[
                Text("I already have account"),
                SizedBox(width:15),
                InkWell(
                  child:Text("Login",style:TextStyle(color:Colors.blue)),
                  onTap:(){
                    Navigator.of(context).pushNamed("login");
                  },
                ),
              ]
          )
        ],
      ),
    );
  }
}

