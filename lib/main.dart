import 'package:flutter/material.dart';
import 'package:Steps4Cause/home.dart';
import 'package:Steps4Cause/landing.dart';
import 'package:Steps4Cause/services/user.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserService>(
      create: (context) => UserService.instance(),
      child: MaterialApp(
          home: Consumer<UserService>(builder: (context, userService, __) {
        return StartupWidget();
      })),
    );
  }
}

class StartupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    return new FutureBuilder(
        future: userService.isCurrentUserVerified(),
        initialData: AuthStatus.undeterminate,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print("ERROR " + snapshot.error.toString());
          print("SNAPSHOT " + snapshot.data.toString());
          switch (snapshot.data) {
            case AuthStatus.authenticated:
              return MyHomePage();
              break;
            case AuthStatus.undeterminate:
              return LoadingWidget();
            default:
              return MyLandingPage();
          }
        });
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
