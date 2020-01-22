import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/utils/env.dart';
import 'package:password/password.dart';


class myLoginPage extends StatefulWidget {
  myLoginPage({Key key, this.title}) : super(key: key);
  final String title;
  // This widget is the root of your application.
  @override
  myLoginPageState createState() => myLoginPageState();
}

class myLoginPageState extends State<myLoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  String token;

  final unController = TextEditingController();
  final pwController = TextEditingController();
  final algorithm = PBKDF2();



  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    unController.dispose();
    pwController.dispose();
    super.dispose();
  }

  String hashPassword(){
    final hash = Password.hash(pwController.text, algorithm);
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      controller: unController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      controller: pwController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          login();
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
//            crossAxisAlignment: CrossAxisAlignment.center,
//            mainAxisAlignment: MainAxisAlignment.center,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    "assets/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 45.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButton,
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
//    var ip = await EnvironmentUtil.getEnvValueForKey('SERVER_IP');
//    print(ip);
    var url = 'http://localhost:5000/users/login';
    final msg =
        jsonEncode({'email': unController.text, 'password': hashPassword()});
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: msg);
    print(msg);
    print(response);
    if(response.statusCode == 200)
      token = json.decode(response.body)['token'];

    if(token != null){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
    else
      print("Wrong Credentials");
    print(token);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
