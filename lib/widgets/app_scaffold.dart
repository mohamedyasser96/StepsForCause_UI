import 'package:flutter/material.dart';

import 'app_drawer.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Color backgroundColor;
  final Widget bottomNavigationBar;

  AppScaffold({this.body, this.backgroundColor, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Steps 4 Cause')),
      body: body,
      drawer: AppDrawer(),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
