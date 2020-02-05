import 'package:flutter/material.dart';
import 'package:Steps4Cause/services/leaderboard.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
    final list = <Widget>[];
    list.add(Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: ListTile(
          leading: new CircularPercentIndicator(
            radius: 51.0,
            // lineWidth: 5.0,
            percent: 1.0,
            center: new Text("9567"),
            progressColor: Colors.blue,
          ),
          title: Text('Total Steps'),
          subtitle: Text("9567"),
        )));

    topTenboard != null
        ? topTenboard.map((v) {
            list.add(ListTile(
              title: Text(v.name),
              subtitle: Text(v.stepCount.toString()),
              leading: new CircularPercentIndicator(
                radius: 50.0,
                // lineWidth: 5.0,
                percent: v.stepCount / 9567,
                center: new Text((v.stepCount / 9567 * 100).ceil().toString()),
                progressColor: Colors.yellow,
              ),
            ));
          }).toList()
        : null;
    return Center(child: ListView(children: list));
  }
}
