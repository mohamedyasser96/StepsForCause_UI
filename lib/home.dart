import 'package:flutter/material.dart';
import 'package:flutter_app/services/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/login.dart';
import 'package:flutter_app/Profile.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  // This widget is the root of your application.
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final status = Provider.of<AuthStatus>(context);

    return new Scaffold(
      body: DefaultTabController(
        length: 4,
        child: new Scaffold(
          body: TabBarView(
            children: [
              MyProfilePage(),
              myLoginPage(),
              new Container(
                color: Colors.lightGreen,
                child: Center(
                  child: MaterialButton(
                    color: Colors.blueGrey,
                    child: Text(status.index.toString()),
                    onPressed: () => userService.signOut(),
                  ),
                ),
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
