import 'package:flutter/material.dart';
import 'package:flutter_app/services/leaderboard.dart';
import 'package:provider/provider.dart';


class MyLeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final leaderboard = Leaderboard();

    return MultiProvider(
        providers: [
          // Make user stream available
          StreamProvider<int>.value(value: leaderboard.totalStepCount),
          StreamProvider<List<UserScore>>.value(value: leaderboard.topTenboard),
        ],

        // All data will be available in this child and descendents
        child: _MyLeaderboardPage());
  }
}

class _MyLeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final totalStepCount = Provider.of<int>(context);
    final topTenboard = Provider.of<List<UserScore>>(context);
    return Center(
      child: ListView(
          children: topTenboard != null
              ? topTenboard.map((v) {
                  return ListTile(
                      title: Text(v.name),
                      subtitle: Text(v.stepCount.toString()));
                }).toList()
              : []),
    );
  }
}
