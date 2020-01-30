import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/landing.dart';
import 'package:flutter_app/services/user.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // Make user stream available
          StreamProvider<AuthStatus>.value(value: userService.status),

          // See implementation details in next sections
          StreamProvider<FirebaseUser>.value(value: userService.user)
        ],

        // All data will be available in this child and descendents
        child: MaterialApp(home: StartupWidget()));
  }
}

class StartupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final status = Provider.of<AuthStatus>(context);
    switch (status) {
      case AuthStatus.authenticated:
        return MyHomePage();
        break;
      case AuthStatus.undeterminate:
        return LoadingWidget();
      default:
        return MyLandingPage();
    }
  }
}

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          new CircularProgressIndicator(),
          new Text("Loading"),
        ],
      ),
    ));
  }
}

void main() => runApp(MyApp());
