import 'package:chat_firebase/helper/helper_function.dart';
import 'package:chat_firebase/main.dart';
import 'package:chat_firebase/pages/group_info.dart';
import 'package:chat_firebase/pages/home_page.dart';
import 'package:chat_firebase/services/auth_services.dart';
import 'package:chat_firebase/services/database_services.dart';
import 'package:chat_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String adminName;

  const GroupInfo(
      {Key? key,
      required this.groupName,
      required this.groupId,
      required this.adminName})
      : super(key: key);
  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  AuthService authService = AuthService();
  Stream? members;
  String userName = "";
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
    await HelperFunctions.getUserNamefromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Text(
          widget.groupName,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: IconButton(
                onPressed: () {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.black,
                          title: const Text(
                            "Leave group",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            "Are you sure you want to leave the group?",
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.cancel,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      size: 30)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: IconButton(
                                  onPressed: () async {
                                    await DatabaseService(
                                            uid: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .toggleJoinOrExit(widget.groupName,
                                            widget.groupId, userName)
                                        .whenComplete(() {
                                      nextScreenReplace(
                                          context, const HomePage());
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 30,
                                  )),
                            )
                          ],
                        );
                      });
                },
                icon: const Icon(
                  Icons.exit_to_app,
                  size: 30,
                )),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.groupName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Group: ${widget.groupName}",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("Admin: ${getName(widget.adminName)}",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            membersList()
          ],
        ),
      ),
    );
  }

  membersList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        child: Text(
                          "A",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text(
                  "NO MEMBERS",
                  style: TextStyle(color: Colors.black),
                ),
              );
            }
          } else {
            return const Center(
                child: Text(
              "NO MEMBERS",
              style: TextStyle(color: Colors.black),
            ));
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }
}
