

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/widgets/button.dart';
import 'package:professional_chat/widgets/input.dart';



class EditPassword extends StatefulWidget {
  EditPassword({super.key,required this.email,required this.password});
    String email;
    String password;
  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  _EditPasswordState();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  void reauthenticateAndChangePassword(String email, String password, String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot newPass = await FirebaseFirestore.instance.collection("users").where('email', isEqualTo: email).get();

    if (user != null) {
      if (user!.email != email){
        print("It's not your email you can't update it .");
      } else{
        try {
          AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

          // Reauthenticate the user
          await user.reauthenticateWithCredential(credential);

          // Now update the password
          await user.updatePassword(newPassword);
          newPass.docs.forEach((element) {
            element.reference.update({
              'password': newPasswordController.text,
            }).then((value) {
              print("Updated successfuly .");
            });
          });
          Navigator.of(context).pop();
          print("Password updated successfully after reauthentication.");
        } catch (e) {
          print("Error during reauthentication or password update: $e");
        }
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.text = widget.email;
    passwordController.text = widget.password;

  }

  @override
  Widget build(BuildContext context) {
    return
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(1))
        ),
        child: Container(
          height: 450,
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Container(
                  child: Text("  Email"),
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
              ),
              SizedBox(height: 3,),
              MyInfoInput(color: Colors.grey,readOnly: true,textEditingController: emailController, IC: Text("")),
              SizedBox(height: 10,),
              Container(
                child: Text("  Password"),
                width: double.infinity,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(height: 3,),
              MyInfoInput(color:Colors.grey,readOnly: true,textEditingController: passwordController, IC: Text('')),
              SizedBox(height: 10,),
              Container(
                child: Text("  New Password"),
                width: double.infinity,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(height: 3,),
              MyInfoInput(color:Colors.white,readOnly: false,textEditingController: newPasswordController, IC: Text('')),
              SizedBox(height: 10,),
              MyButton(text: "Save", onTap: (){
                reauthenticateAndChangePassword(emailController.text, passwordController.text, newPasswordController.text);
              })
            ],
          ),
        ),
      ) ;
  }
}
