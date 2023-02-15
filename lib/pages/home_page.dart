import 'package:chat_firebase/helper/helper_function.dart';
import 'package:chat_firebase/main.dart';
import 'package:chat_firebase/pages/auth/login_page.dart';
import 'package:chat_firebase/pages/profile_page.dart';
import 'package:chat_firebase/pages/search_page.dart';
import 'package:chat_firebase/services/auth_services.dart';
import 'package:chat_firebase/services/database_services.dart';
import 'package:chat_firebase/widgets/group_tiles.dart';
import 'package:chat_firebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String userName = "";
  String email = "";
  String groupName = "";
  AuthService authService = AuthService();
  Stream? groups;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getGroupId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getGroupName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getUserData() async {
    await HelperFunctions.getUserEmailfromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    await HelperFunctions.getUserNamefromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      groups = snapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => {nextScreen(context, const SearchPage())},
            icon: const Icon(
              Icons.search,
              color: Color.fromARGB(255, 255, 230, 0),
            ),
          )
        ],
        centerTitle: true,
        title: const Text(
          "Groups",
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 230, 0)),
        ),
      ),
      drawer: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              const Icon(
                Icons.account_circle,
                size: 150,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                userName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              ListTile(
                onTap: () {},
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(
                  Icons.group,
                  color: Colors.white,
                ),
                title: const Text(
                  "Groups",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              ListTile(
                onTap: () {
                  nextScreen(
                      context,
                      ProfilePage(
                        userName: userName,
                        email: email,
                      ));
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                title: const Text(
                  "Profile",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              ListTile(
                  onTap: () async {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Logout"),
                            content:
                                const Text("Are you sure you want to logout?"),
                            actions: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  )),
                              IconButton(
                                  onPressed: () async {
                                    await authService.signOut();
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LogInPage()),
                                        (route) => false);
                                  },
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ))
                            ],
                          );
                        });
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ))
            ],
          )),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
          size: 40,
        ),
      ),
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: ((context, index) {
                    int reverseindex =
                        snapshot.data['groups'].length - 1 - index;
                    return GroupTile(
                        userName: snapshot.data['username'],
                        groupName:
                            getGroupName(snapshot.data['groups'][reverseindex]),
                        groupId:
                            getGroupId(snapshot.data['groups'][reverseindex]));
                  }));
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
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

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: ((context, setState) {
              return AlertDialog(
                backgroundColor: Colors.black,
                title: const Text(
                  "Create new group",
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  textAlign: TextAlign.left,
                ),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              groupName = val;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(30)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.white),
                        )
                ]),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0, primary: Theme.of(context).primaryColor),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (groupName != "") {
                        setState(() {
                          _isLoading = true;
                        });
                        DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .createGroup(
                                userName,
                                FirebaseAuth.instance.currentUser!.uid,
                                groupName)
                            .whenComplete(() {
                          _isLoading = false;
                        });
                        showSnackBar(context, Colors.green,
                            "Group created successfully");
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0, primary: Theme.of(context).primaryColor),
                    child: const Text("Create",
                        style: TextStyle(color: Colors.black)),
                  )
                ],
              );
            }),
          );
        });
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  popUpDialog(context);
                },
                child: Icon(
                  Icons.add_circle,
                  size: 75,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "There are no groups currently, please create a new group or search for existing groups",
                textAlign: TextAlign.center,
              )
            ]),
      ),
    );
  }
}
