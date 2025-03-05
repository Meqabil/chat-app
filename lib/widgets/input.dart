import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hint;
  final bool hideText;

  MyInput({
    required this.textEditingController,
    required this.hint,
    required this.hideText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 11),
      margin: const EdgeInsets.all(3),
      child: TextFormField(
        obscureText: hideText,
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: hint,
          hoverColor: Colors.white,
          hintStyle: const TextStyle(
            color: Colors.blue,
          ),
          fillColor: Colors.white38,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Controls height
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(90)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(80)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class InfoInput extends StatelessWidget {
  InfoInput({super.key,required this.hideText,required this.textEditingController});
  bool hideText;
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1,horizontal: 11),
      margin: EdgeInsets.all(3),
      color: Colors.white24,
      child: TextFormField(
        obscureText: hideText,
        controller: textEditingController,
        decoration: InputDecoration(
          hoverColor: Colors.white,
          hintStyle: TextStyle(
            color: Colors.blue,
          ),
          fillColor: Colors.white38,
          label: null,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(90))
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(80)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}


class MyInfoInput extends StatelessWidget{
  TextEditingController textEditingController = TextEditingController();
  MyInfoInput({required this.textEditingController,required this.IC,required this.readOnly,required this.color});
  bool readOnly;
  Color color;
  Widget IC;
  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1,horizontal: 11),
      margin: EdgeInsets.all(3),
      child: TextFormField(

        readOnly: readOnly,
        controller: textEditingController,
        style: TextStyle(
          color: color,
        ),
        decoration: InputDecoration(
          suffixIcon: IC,
          labelStyle: TextStyle(
            color: Colors.red,
          ),
          label: null,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class SendInput extends StatelessWidget{
  TextEditingController textEditingController = TextEditingController();
  String hint ;
  bool hideText;
  SendInput({required this.textEditingController,required this.hint,required this.hideText});
  @override
  Widget build(BuildContext context){
    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 0,horizontal: 3),
      margin: EdgeInsets.all(3),
      child: TextFormField(
        style: TextStyle(
          fontSize: 16,
        ),
        obscureText: hideText,
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: hint ?? "hint",
          hoverColor: Colors.white,
          hintStyle: TextStyle(
            color: Colors.blue,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
          fillColor: Colors.white38,
          label: null,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(90))
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(80)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}