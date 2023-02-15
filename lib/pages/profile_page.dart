import 'package:chat_firebase/main.dart';
import 'package:chat_firebase/pages/home_page.dart';
import 'package:chat_firebase/pages/search_page.dart';
import 'package:chat_firebase/services/auth_services.dart';
import 'package:chat_firebase/pages/auth/login_page.dart';
import 'package:chat_firebase/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../helper/helper_function.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  ProfilePage({Key? key, required this.userName, required this.email})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        actions: [
          IconButton(
              onPressed: (() {
                nextScreen(context, const SearchPage());
              }),
              icon: const Icon(
                Icons.search,
                color: Color.fromARGB(255, 255, 230, 0),
                size: 30,
              )),
        ],
        centerTitle: true,
        title: const Text("Profile",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255))),
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
                widget.userName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              ListTile(
                onTap: () {
                  nextScreenReplace(context, const HomePage());
                },
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
                selected: true,
                onTap: () {},
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
                    await authService.signOut().whenComplete(() {
                      nextScreenReplace(context, const LogInPage());
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.account_circle,
              size: 200,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Username",
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 17),
                )
              ],
            ),
            const Divider(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email",
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(fontSize: 17),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
