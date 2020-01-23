import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/verification.dart';
//import 'package:image_picker_modern/image_picker_modern.dart';
import 'dart:io';
import 'dart:developer' as dev;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:password/password.dart';


class myRegisterPage extends StatefulWidget {
  myRegisterPage({Key key, this.title}) : super(key: key);
  final String title;

  // This widget is the root of your application.
  @override
  _myRegisterPageState createState() => _myRegisterPageState();
}
class _myRegisterPageState extends State<myRegisterPage> {
  final fnController = TextEditingController();
  final lnController = TextEditingController();
  final emController = TextEditingController();
  final pwController = TextEditingController();
  final algorithm = PBKDF2();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  File _image;
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fnController.dispose();
    lnController.dispose();
    emController.dispose();
    pwController.dispose();
    super.dispose();
  }

  String hashPassword(){
    final hash = Password.hash(pwController.text, algorithm);
    return hash;
  }
  @override
  Widget build(BuildContext context) {
    final floating = FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo)
    );
    final firstNameField = TextField(
      controller: fnController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "First Name",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final lastNameField = TextField(
      controller: lnController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Last Name",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final emailField = TextField(
      controller: emController,
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
    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          register();

          },
        child: Text("Register",
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
              children:
                <Widget>[
                  (_image == null ? Text('No image selected.') : Image.file(_image)),
                  SizedBox(height: 10.0),
                  floating,
                  SizedBox(height: 20.0),
                  firstNameField,
                  SizedBox(height: 20.0),
                  lastNameField,
                  SizedBox(height: 20.0),
                  emailField,
                  SizedBox(height: 20.0),
                  passwordField,
                  SizedBox(
                    height: 20.0,
                  ),
                  registerButton,
                  SizedBox(
                    height: 15.0,
                  ),

                ],
//                 floatingActionButton: FloatingActionButton(
//                  onPressed: getImage,
//                  tooltip: 'Pick Image',
//                  child: Icon(Icons.add_a_photo),
//                ),



              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,


            ),
          ),
        ),
      ),
    );
  }
  Future getImage() async {
    dev.log("fdaad");
//    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
//      _image = image;
    });
  }
  void register()async {
    var url = 'http://172.20.10.6:5000/users';
    final msg = jsonEncode({'firstName':fnController.text, 'lastName':lnController.text, 'email': emController.text, 'password': hashPassword()});
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: msg);
    print(msg);
    if(response.statusCode == 200)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => myVerificationPage(email: emController.text)),
        );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
