import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  MyButton({super.key,required this.text,required this.onTap});
  final void Function()?onTap;
  String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(11),
      child: ElevatedButton(onPressed: onTap,
      child: Text("${text}",style: TextStyle(color: Colors.blue,fontSize: 16),),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.width, 50),
          //backgroundColor: Colors.white,
          textStyle: TextStyle(color: Colors.blue,fontSize: 16),
          side: BorderSide(
            width: 1,
            color: Colors.grey,
          )
        ),
      ),
    );
  }
}
