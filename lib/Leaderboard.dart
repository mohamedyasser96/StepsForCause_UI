import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_table/json_table.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyLeaderboardPage extends StatefulWidget {
  MyLeaderboardPage({Key key, this.title}) : super(key: key);
  final String title;
  // This widget is the root of your application.
  @override
  _MyLeaderboardPageState createState() => _MyLeaderboardPageState();
}

class _MyLeaderboardPageState extends State<MyLeaderboardPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  var jsonSample =
      '[{"name":"Ram","email":"ram@gmail.com","age":23,"income":"10Rs","country":"India","area":"abc"},{"name":"Shyam","email":"shyam23@gmail.com",'
      '"age":28,"income":"30Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"John","email":"john@gmail.com","age":33,"income":"15Rs","country":"India",'
      '"area":"abc","day":"Monday","month":"april"},{"name":"Ram","email":"ram@gmail.com","age":23,"income":"10Rs","country":"India","area":"abc","day":"Monday","month":"april"},'
      '{"name":"Shyam","email":"shyam23@gmail.com","age":28,"income":"30Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"John","email":"john@gmail.com",'
      '"age":33,"income":"15Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"Ram","email":"ram@gmail.com","age":23,"income":"10Rs","country":"India",'
      '"area":"abc","day":"Monday","month":"april"},{"name":"Shyam","email":"shyam23@gmail.com","age":28,"income":"30Rs","country":"India","area":"abc","day":"Monday","month":"april"},'
      '{"name":"John","email":"john@gmail.com","age":33,"income":"15Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"Ram","email":"ram@gmail.com","age":23,'
      '"income":"10Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"Shyam","email":"shyam23@gmail.com","age":28,"income":"30Rs","country":"India","area":"abc",'
      '"day":"Monday","month":"april"},{"name":"John","email":"john@gmail.com","age":33,"income":"15Rs","country":"India","area":"abc","day":"Monday","month":"april"}]';
  bool toggle = true;

  var ip;
  var port;
  var token;
  var users;

  void initState() {
    super.initState();
    setEnv();
    getUsers();
  }

  getUsers() async {
    //getting token
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? null;
    var url = 'http://' + ip + ':' + port + '/users';
    print(url);
    try {
      var response = await http.get(url, headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      });


      var j = json.decode(response.body)['users'];
      print(j);
//      setState(() {
//        jsonSample = j.toString();
//      });
    } catch (err) {
      print("error" + err);
    }
  }

  Future setEnv() async {
    //getting env values
    await DotEnv().load('.env');
    port = DotEnv().env['PORT'];
    ip = DotEnv().env['SERVER_IP'];
  }

//  @override
  Widget build(BuildContext context) {
    var json = jsonDecode(jsonSample);
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Leaderboard"),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: toggle
            ? Column(
                children: [
                  JsonTable(
                    json,
                    showColumnToggle: true,
                    tableHeaderBuilder: (String header) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            color: Colors.grey[300]),
                        child: Text(
                          header,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.display1.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0,
                              color: Colors.black87),
                        ),
                      );
                    },
                    tableCellBuilder: (value) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 0.5,
                                color: Colors.grey.withOpacity(0.5))),
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.display1.copyWith(
                              fontSize: 14.0, color: Colors.grey[900]),
                        ),
                      );
                    },
                    allowRowHighlight: true,
                    rowHighlightColor: Colors.yellow[500].withOpacity(0.7),
                    paginationRowCount: 6,
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Text("Here are the top users")
                ],
              )
            : Center(
                child: Text(getPrettyJSONString(jsonSample)),
              ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.grid_on),
          onPressed: () {
            setState(
              () {
                toggle = !toggle;
              },
            );
          }),
    );
  }

  String getPrettyJSONString(jsonObject) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(json.decode(jsonObject));
    return jsonString;
  }
}
