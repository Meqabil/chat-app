import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  File? image;
  ImagePicker picker = ImagePicker();

  pickImage() async{
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if(pickedImage != null){
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  // uploadImageToFirebase(BuildContext context,File image) async {
  //   try {
  //     // Create a storage reference
  //     String fileName = basename(image.path); // Extract file name
  //     Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
  //     // Upload the file to Firebase Storage
  //     UploadTask uploadTask = firebaseStorageRef.putFile(image);
  //     // Monitor the upload progress
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false, // Prevents dismissing the dialog while uploading
  //       builder: (BuildContext context) {
  //         return UploadProgressDialog(uploadTask: uploadTask);
  //       },
  //     );
  //     // Get the download URL once the upload is complete
  //     TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  //     String downloadURL = await taskSnapshot.ref.getDownloadURL();
  //     print('File uploaded successfully. Download URL: $downloadURL');
  //     return downloadURL;
  //   } catch (e) {
  //     print('Error occurred while uploading image: $e');
  //   }
  // }
  Future<String?> uploadImage(File image) async{
    try{
      String fileName = basename(image.path);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageurl = await taskSnapshot.ref.getDownloadURL();
      imageUrl = imageUrl;
      return imageurl;
    } catch (e){
      print('Error occurred while uploading image : $e ');
    }
  }
  List<String> selectedUsers = []; // List of selected user IDs
  TextEditingController groupNameController = TextEditingController();
  FirebaseAuth user = FirebaseAuth.instance;
  String imageUrl = 'empty';
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              InkWell(
                child:image == null ? Image.asset('assets/group_cover.png',width: double.infinity,height: 210,fit: BoxFit.cover,): Image.file(image!,fit: BoxFit.cover,width: double.infinity,height: 210,),
                onTap: (){
                  pickImage();
                },
              ),
              TextField(
                controller: groupNameController,
                cursorColor: Colors.deepPurple,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple)
                  ),
                  labelText: "Group Name",
                  labelStyle: TextStyle(color: Colors.deepPurple),

                ),
              ),
              Expanded(

              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                        title: Text(users[index]['name']),
                        value: selectedUsers.contains(users[index]['uid']) ,
                        activeColor: Colors.blue,
                        onChanged: (isChecked) {
                          setState(() {
                            if (isChecked == true) {
                               selectedUsers.add(users[index]['uid']);
                               print(selectedUsers);
                            } else {
                              selectedUsers.remove(users[index]['uid']);
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
                child: Text("Create Group"),
                onPressed: () {
                  createGroup(context,groupNameController.text, selectedUsers);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: Size(double.maxFinite, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to create a group in Firestore
  Future<void> createGroup(BuildContext context,String groupName, List<String> members) async {
    FirebaseFirestore.instance.collection('groups').add({
      'groupName': groupName,
      'groupCover': await uploadImage(image!) ?? imageUrl,
      'members': members, // Array of selected user IDs
      'adminId' : user.currentUser!.uid,
    }).then((value){
      Navigator.of(context).pop();
    });
  }
}
