import 'package:flutter/material.dart';
import 'package:flutter_app/services/user.dart';
import 'package:flutter_app/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/Leaderboard.dart';
import 'package:flutter_app/Profile.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final status = Provider.of<AuthStatus>(context);
    return DefaultTabController(
      length: 3,
      child: new AppScaffold(
        body: TabBarView(
          children: [
            MyProfilePage(),
            MyLeaderboardPage(),
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
          ],
        ),
        bottomNavigationBar: new TabBar(
          labelPadding: EdgeInsets.only(bottom: 4.0),
          tabs: [
            Tab(
              icon: new Icon(Icons.home),
            ),
            Tab(
              icon: new Icon(Icons.score),
            ),
            Tab(
              icon: new Icon(Icons.history),
            ),
          ],
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Colors.red,
          indicatorPadding: EdgeInsets.only(bottom: 8.0),
        ),
        backgroundColor: Colors.black,
      ),
    );
  }
}
