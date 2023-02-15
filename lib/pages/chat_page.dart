import 'package:chat_firebase/pages/group_info.dart';
import 'package:chat_firebase/pages/home_page.dart';
import 'package:chat_firebase/services/database_services.dart';
import 'package:chat_firebase/widgets/messages_tiles.dart';
import 'package:chat_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String userName;
  const ChatPage(
      {Key? key,
      required this.groupName,
      required this.groupId,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  Stream<QuerySnapshot>? chats;
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getChats(widget.groupId)
        .then((value) {
      setState(() {
        chats = value;
      });
    });

    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmin(widget.groupId)
        .then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: IconButton(
                  onPressed: () {
                    nextScreen(
                        context,
                        GroupInfo(
                            groupName: widget.groupName,
                            groupId: widget.groupId,
                            adminName: admin));
                  },
                  icon: const Icon(
                    Icons.info_outline,
                    size: 30,
                    color: Color.fromARGB(255, 255, 230, 0),
                  )),
            )
          ],
          backgroundColor: Colors.black,
          centerTitle: false,
          title: Text(
            widget.groupName,
            style: const TextStyle(
                color: Color.fromARGB(255, 255, 230, 0),
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: <Widget>[
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
                child: Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Send a message...",
                        hintStyle:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                          child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 40,
                      )),
                    ),
                  )
                ]),
              ),
            )
          ],
        ));
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageData = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      DatabaseService().sendMessage(chatMessageData, widget.groupId);
      setState(() {
        messageController.clear();
      });
    }
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender']);
                })
            : Container();
      },
    );
  }
}
