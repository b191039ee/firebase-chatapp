import 'dart:isolate';

import 'package:chat_firebase/helper/helper_function.dart';
import 'package:chat_firebase/pages/chat_page.dart';
import 'package:chat_firebase/pages/home_page.dart';
import 'package:chat_firebase/services/database_services.dart';
import 'package:chat_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool hasUserSearched = false;
  QuerySnapshot? searchSnapshot;
  String userName = "";
  bool _isJoined = false;
  bool _isLoading = false;
  TextEditingController searchController = TextEditingController();
  User? user;
  @override
  void initState() {
    getUserNameAndId();
    super.initState();
  }

  getUserNameAndId() async {
    await HelperFunctions.getUserNamefromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    user = FirebaseAuth.instance.currentUser;
  }

  getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text(
          "Search",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        elevation: 0,
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          color: Theme.of(context).primaryColor,
          child: Row(children: [
            Expanded(
                child: TextFormField(
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: "Enter group name..."),
              controller: searchController,
            )),
            GestureDetector(
              onTap: () {
                initializeSearch();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(17)),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            )
          ]),
        ),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor),
              )
            : groupList()
      ]),
    );
  }

  initializeSearch() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
      await DatabaseService()
          .getGroupByName(searchController.text)
          .then((value) {
        searchSnapshot = value;
        hasUserSearched = true;
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            itemCount: searchSnapshot!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return groupTiles(
                userName,
                searchSnapshot!.docs[index]['groupName'],
                searchSnapshot!.docs[index]['groupId'],
                searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : const Center(
            child: Text("Search Key is case sensitive"),
          );
  }

  joinedOrNot(
      String groupName, String groupId, String userName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        _isJoined = value;
      });
    });
  }

  Widget groupTiles(
      String userName, String groupName, String groupId, String admin) {
    joinedOrNot(groupName, groupId, userName, admin);
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          radius: 30,
          child: Text(
            groupName.substring(0, 1).toUpperCase(),
            style:
                TextStyle(fontSize: 32, color: Theme.of(context).primaryColor),
          ),
        ),
        title: Text(
          groupName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          "Admin: ${getName(admin)}",
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w300, fontSize: 13),
        ),
        trailing: InkWell(
          onTap: () async {
            await DatabaseService(uid: user!.uid)
                .toggleJoinOrExit(groupName, groupId, userName);
            if (_isJoined) {
              setState(() {
                _isJoined = !_isJoined;
              });
              showSnackBar(context, Colors.red, "Exited group $groupName");
            } else {
              setState(() {
                _isJoined = !_isJoined;
              });
              showSnackBar(
                  context, Colors.green, "Now joined group $groupName");
              Future.delayed(const Duration(seconds: 2), () {
                nextScreen(
                    context,
                    ChatPage(
                        groupName: groupName,
                        groupId: groupId,
                        userName: userName));
              });
            }
          },
          child: _isJoined
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    "Joined",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 230, 0),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    "Join Now",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w600),
                  ),
                ),
        ));
  }
}
