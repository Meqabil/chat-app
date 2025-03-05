import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:professional_chat/widgets/button.dart';
import 'package:professional_chat/widgets/input.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Login Function
  loginWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.of(context).pushNamed("chatrooms");
      // Login successful
      print('User logged in: ${userCredential.user?.email}');
      // Navigate to home screen or another page
    } catch (e) {
      print('Login failed: $e');
      // Display an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login",style: TextStyle(color: Colors.blue),),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 12,),
          MyInput(
            textEditingController: _emailController,
            hint: "Email",
            hideText: false,
          ),
          SizedBox(height: 12,),
          MyInput(
            textEditingController: _passwordController,
            hint: "Password",
            hideText: true,
          ),
          SizedBox(height: 12,),
          MyButton(
            text: "Login",
            onTap: (){
              loginWithEmailAndPassword();
            },
          ),
          Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children:[
                Text("I don't have account"),
                SizedBox(width:15),
                InkWell(
                  child:Text("Sign Up",style:TextStyle(color:Colors.blue)),
                  onTap:(){
                    Navigator.of(context).pushReplacementNamed("signup");
                  },
                ),
              ]
          )
        ],
      ),
    );
  }
}
