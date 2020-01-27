import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/home.dart';
class myVerificationPage extends StatefulWidget {
  final String email;
  myVerificationPage({Key key, this.title, @required this.email}) : super(key: key);
  final String title;
  // This widget is the root of your application.
  @override
  _myVerificationPageState createState() => _myVerificationPageState(this.email);
}
class _myVerificationPageState extends State<myVerificationPage> {
  final String email;
  _myVerificationPageState(this.email);
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final verificationCodeController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verificationCodeField = TextField(
      controller: verificationCodeController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Verification code",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          verifyUser(this.email, verificationCodeController.text);
        },
        child: Text("Validate",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    "assets/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20.0),
                verificationCodeField,
                SizedBox(
                  height: 20.0,
                ),
                registerButton,
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

  void verifyUser(email, verificationCode) async {
    print('EMAIL ${email}');
    var url = 'http://172.20.10.6:5000/verificationCode';
    final msg = jsonEncode({'email':email, 'verificationCode': verificationCode});
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: msg);
    print(msg);
    if(response.statusCode == 200)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    else
      _showDialog(json.decode(response.body)['error']);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  void _showDialog(err) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Incorrect!"),
          content: new Text(err),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
