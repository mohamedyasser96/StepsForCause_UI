import 'package:flutter/material.dart';
import 'package:flutter_app/services/user.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 8.0),
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                  userService.user != null ? userService.user.email : 'wow'),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                userService.signOut();
              },
            )
          ],
        ),
      ),
    );
  }
}
