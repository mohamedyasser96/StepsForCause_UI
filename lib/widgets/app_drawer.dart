import 'package:Steps4Cause/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<Services>(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 8.0),
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                  service.userService.user != null ? service.userService.user.email : 'wow'),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                service.userService.signOut();
              },
            )
          ],
        ),
      ),
    );
  }
}
