import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart' show StreamGroup;

class Leaderboard {
  Stream<int> totalStepCountUsers;
  Stream<int> totalStepCountTeams;
  Stream<int> totalStepCount;
  Stream<List<UserScore>> topTenboardUsers;
  Stream<List<UserScore>> topTenboardTeams;
  Stream<List<UserScore>> topTenboard;
  final _firestore = Firestore.instance;

  Leaderboard() {
    topTenboardUsers = _firestore
        .collection("users")
        .orderBy('stepCount')
        .limit(10)
        .snapshots()
        .map((users) {
      List<UserScore> topTenUsers = new List();
      users.documents.forEach((user) {
        UserScore userScore = UserScore.fromMap(user.data);
        topTenUsers.add(userScore);
      });
      return topTenUsers;
    });

    topTenboardTeams = _firestore
        .collectionGroup("members")
        .orderBy('stepCount', descending: true)
        .limit(10)
        .snapshots()
        .map((users) {
      List<UserScore> topTenUsers = new List();
      users.documents.forEach((user) {
        UserScore userScore = UserScore.fromMap(user.data);
        topTenUsers.add(userScore);
      });
      return topTenUsers;
    });

    totalStepCountUsers = _firestore
        .collection("users")
        .orderBy('stepCount')
        .snapshots()
        .map((users) {
      int totalSteps = 0;
      users.documents.forEach((user) {
        totalSteps += user.data['stepCount'];
      });
      return totalSteps;
    });

    totalStepCountTeams = _firestore
        .collection("/teams")
        .orderBy("totalSteps")
        .snapshots()
        .map((teams) {
      int totalSteps = 0;
      teams.documents.forEach((team) {
        totalSteps += team['totalSteps'];
      });
      return totalSteps;
    });

    int totalSteps = 0;
    totalStepCount =
        StreamGroup.merge([totalStepCountUsers, totalStepCountTeams])
            .map((val) {
      totalSteps += val;
      return totalSteps;
    });

    List<UserScore> topUsers = new List();
    topTenboard =
        StreamGroup.merge(([topTenboardUsers, topTenboardTeams])).map((list) {
      topUsers += list;
      topUsers.sort();

      if (topUsers.length > 10)
        topUsers.removeRange(10, topUsers.length - 1);
      return topUsers;
    });
  }
}

class UserScore implements Comparable {
  final String name;
  final int stepCount;

  UserScore({this.name, this.stepCount});

  factory UserScore.fromMap(Map data) {
    data = data ?? {};
    return UserScore(
        name: data['name'] ?? '', stepCount: data['stepCount'] ?? 0);
  }

  @override
  int compareTo(other) {
    int retVal;
    if (stepCount < other.stepCount)
      retVal = 1;
    else if (stepCount > other.stepCount)
      retVal = -1;
    else retVal = 0;

    return retVal;
  }
}
