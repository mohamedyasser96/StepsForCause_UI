import 'package:flutter/material.dart';
import 'package:Steps4Cause/services/user.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:password/password.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);
  final String title;

  // This widget is the root of your application.
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fnController = TextEditingController();
  final lnController = TextEditingController();
  final emController = TextEditingController();
  final pwController = TextEditingController();
  final algorithm = PBKDF2();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  File _image;
  var ip;
  var port;

  void initState() {
    super.initState();
    setEnv();
  }

  Future setEnv() async {
    // await DotEnv().load('.env');
    // port = DotEnv().env['PORT'];
    // ip = DotEnv().env['SERVER_IP'];
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fnController.dispose();
    lnController.dispose();
    emController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floating = FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo));
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
          register(context);
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
            child: ListView(
              children: <Widget>[
                (_image == null
                    ? Text('No image selected.')
                    : Image.file(_image)),
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

              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 240.0,
      maxWidth: 240.0,
    );

    var base64Image = image != null
        ? 'data:image/png;base64,' + base64Encode(image.readAsBytesSync())
        : '';

    setState(() {
      _image = image;
    });
  }

  void register(BuildContext context) async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);

      await userService.signUpWithEmailAndPassword(emController.text,
          fnController.text + " " + lnController.text, pwController.text);
      _showDialog(
          "Verification", "Please confirm your email address and login.");
    } catch (e) {
      print(e);
      _showDialog("Failed", "Failed to register user, please try again.");
    }
  }

  void _showDialog(head, txt) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(head),
          content: new Text(txt),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
