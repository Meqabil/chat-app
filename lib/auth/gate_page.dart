import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}


class _GateState extends State<Gate> {
  userState(){
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("signup");
      } else {
        Navigator.of(context).pushReplacementNamed("chatrooms");
      }
    });
  }
  @override
  void initState() {
    super.initState();
    userState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
