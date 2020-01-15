import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/verification.dart';
//import 'package:image_picker_modern/image_picker_modern.dart';
import 'dart:io';
import 'dart:developer' as dev;
import 'dart:async';



class myRegisterPage extends StatefulWidget {
  myRegisterPage({Key key, this.title}) : super(key: key);
  final String title;

  // This widget is the root of your application.
  @override
  _myRegisterPageState createState() => _myRegisterPageState();
}
class _myRegisterPageState extends State<myRegisterPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  File _image;
  @override
  Widget build(BuildContext context) {
    final floating = FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo)
    );
    final firstNameField = TextField(
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "First Name",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final lastNameField = TextField(
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Last Name",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final emailField = TextField(
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
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
        onPressed: () { Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => myVerificationPage()),
        );},
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
}
