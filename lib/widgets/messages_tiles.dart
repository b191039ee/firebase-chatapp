import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  const MessageTile(
      {Key? key,
      required this.message,
      required this.sender,
      required this.sentByMe})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 8,
          right: widget.sentByMe ? 8 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        margin: widget.sentByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(20))
                : const BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(10)),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Color.fromARGB(255, 26, 26, 26)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            widget.sender.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: widget.sentByMe
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: -0.2),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: widget.sentByMe ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          )
        ]),
      ),
    );
  }
}
