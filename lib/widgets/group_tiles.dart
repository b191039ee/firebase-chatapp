import 'package:chat_firebase/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../pages/chat_page.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupName;
  final String groupId;
  const GroupTile(
      {Key? key,
      required this.userName,
      required this.groupName,
      required this.groupId})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
                groupName: widget.groupName,
                groupId: widget.groupId,
                userName: widget.userName));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black,
            child: Text(widget.groupName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    color: Color.fromARGB(255, 255, 230, 0), fontSize: 20)),
          ),
          title: Text(
            widget.groupName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            "Tap to join conversation",
            style: TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
