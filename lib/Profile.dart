import 'package:flutter/material.dart';
import 'dart:typed_data';

class MyProfilePage extends StatefulWidget {
  MyProfilePage({Key key, this.title}) : super(key: key);
  final String title;
  // This widget is the root of your application.
  @override
  MyProfilePageState createState() => MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  var ip;
  var port;
  var token;
  var imageBytes;
  Uint8List bytes;
  Uint8List image64;
  getUser() async {}

  void initState() {
    super.initState();
  }

//  @override
  Widget build(BuildContext context) {
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
                      if (bytes != null)
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: Image.memory(
                            image64,
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blueAccent,
                          child: Image.asset(
                            'logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      new Text(
                        "1200 steps",
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
