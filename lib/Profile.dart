import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:password/password.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  getUser() async {
    //getting token
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? null;
    var url = 'http://' + ip + ':' + port + '/users/user';
    print(url);
    try {
      var response = await http.get(url, headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      });

      imageBytes = json.decode(response.body)['user']["image"];
      final UriData data = Uri.parse(imageBytes).data;
      print(data.isBase64);
      bytes = data.contentAsBytes();
      setState(() {
        image64 = bytes;
      });
    } catch (err) {
      print("error" + err);
    }
  }

  void initState() {
    super.initState();
    setEnv();
    getUser();
  }

  Future setEnv() async {
    //getting env values
    await DotEnv().load('.env');
    port = DotEnv().env['PORT'];
    ip = DotEnv().env['SERVER_IP'];

  }

//  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Profile"),
      ),
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
