import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  bool isSeen;

  MessageBubble({super.key,required this.message, required this.isMe,required this.isSeen});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: !isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
          decoration: BoxDecoration(
            color: !isMe ? Theme.of(context).colorScheme.primary : Colors.blue,
            borderRadius:isMe ? const BorderRadius.only(topRight: Radius.circular(15),bottomRight: Radius.circular(15),topLeft: Radius.circular(15))
                : const BorderRadius.only(bottomLeft: Radius.circular(15),topLeft: Radius.circular(15),topRight: Radius.circular(15)),
          ),
          width: 176,
          padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          margin:const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isMe ? Icon(Icons.done_all, color: isSeen ? Colors.purple : Colors.white ,size: 15,): const Text(''),
              const SizedBox(width: 5,),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: !isMe ? Theme.of(context).colorScheme.inversePrimary  : Colors.white,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class MessageBubble2 extends StatelessWidget {
  final String message;
  final bool isMe;
  bool isSeen;
  MessageBubble2({super.key, required this.message, required this.isMe,required this.isSeen});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: !isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
          decoration: BoxDecoration(
            color: !isMe ? Theme.of(context).colorScheme.primary : Colors.blue,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          width: 176,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isMe ? Icon(Icons.done_all, color: isSeen ? Colors.purple : Colors.white ,size: 15,): const Text(''),
              const SizedBox(width: 5,),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: !isMe ? Theme.of(context).colorScheme.inversePrimary : Colors.white,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
