import 'package:flutter/material.dart';
import 'package:flutter_app/services/steps.dart';
import 'package:flutter_app/services/user.dart';
import 'package:provider/provider.dart';

class MyProfilePage extends StatelessWidget {
  final style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final stepsService = StepsService.instance();
  final start = true;

//  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: ListView(
              children: <Widget>[
                new Container(
                  color: Colors.white,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blueAccent,
                        child: Image.asset(
                          'logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      new Text(
                        userService.user.stepCount.toString(),
                        textScaleFactor: 1.5,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
