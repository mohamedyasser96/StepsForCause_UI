import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  // This widget is the root of your application.
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  var imageBytes;
  Uint8List bytes;
  Uint8List image64;
  getUser() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token')?? null;

    var url = 'http://localhost:5000/users/user';

    try{
      var response = await http.get(url,
          headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'});

      imageBytes = json.decode(response.body)['user']["image"];
      final UriData data = Uri.parse(imageBytes).data;
      print(data.isBase64);
      bytes = data.contentAsBytes();
      setState(() {
        image64 = bytes;
      });
    }catch(err){
      print("error" + err);
    }

  }
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Profile"),
      ),
      body: DefaultTabController(
        length: 4,
        child: new Scaffold(
          body: TabBarView(
            children: [
              new Container(
                color: Colors.white,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if(bytes != null)
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
                    )
              ,
                    new Text(
                      "1200 steps",
                      textScaleFactor: 1.5,
                    )
                  ],
                ),
              ),
              new Container(
                color: Colors.orange,
              ),
              new Container(
                color: Colors.lightGreen,
              ),
              new Container(
                color: Colors.red,
              ),
            ],
          ),
          bottomNavigationBar: new TabBar(
            tabs: [
              Tab(
                icon: new Icon(Icons.home),
              ),
              Tab(
                icon: new Icon(Icons.rss_feed),
              ),
              Tab(
                icon: new Icon(Icons.perm_identity),
              ),
              Tab(
                icon: new Icon(Icons.settings),
              )
            ],
            labelColor: Colors.yellow,
            unselectedLabelColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Colors.red,
          ),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
