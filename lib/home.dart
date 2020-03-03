import 'package:Steps4Cause/Share.dart';
import 'package:Steps4Cause/services/leaderboard.dart';
import 'package:flutter/material.dart';
import 'package:Steps4Cause/setting.dart';
import 'package:Steps4Cause/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:Steps4Cause/leaderboard.dart';
import 'package:Steps4Cause/Profile.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final leaderboard = Leaderboard();
    return MultiProvider(
        providers: [
          // Make user stream available
          StreamProvider<int>.value(value: leaderboard.totalStepCountUsers),
          StreamProvider<String>.value(value: leaderboard.totalStepCountTeams),
          StreamProvider<List<dynamic>>.value(value: leaderboard.topTenboard),
        ],

        // All data will be available in this child and descendents
        child: _MyHomePage());
  }
}

class _MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: new AppScaffold(
        body: TabBarView(
          children: [
            MyProfilePage(),
            MyLeaderboardPage(),
            SocialSharePage(),
            SettingsPage(),
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
              icon: new Icon(Icons.rss_feed),
            ),
            Tab(
              icon: new Icon(Icons.settings),
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
