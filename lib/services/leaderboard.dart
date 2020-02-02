import 'package:firebase_database/firebase_database.dart';

class Leaderboard {
  Stream<int> totalStepCount;
  Stream<List<UserScore>> topTenboard;

  final _db = FirebaseDatabase.instance;

  Leaderboard() {
    topTenboard = _db
        .reference()
        .child("users")
        .orderByChild('stepCount')
        .limitToLast(10)
        .onValue
        .map((change) {
      var v = Map<String, Map>.from(change.snapshot.value);
      final List<UserScore> datalist = [];
      v.forEach((key, value) {
        datalist.add(UserScore.fromMap(value));
      });
      datalist.sort((a, b) => b.stepCount - a.stepCount);
      print(datalist);
      print(v);
      return datalist;
    });
  }
}

class UserScore {
  final String name;
  final int stepCount;

  UserScore({this.name, this.stepCount});

  factory UserScore.fromMap(Map data) {
    data = data ?? {};
    return UserScore(
        name: data['name'] ?? '', stepCount: data['stepCount'] ?? 0);
  }
}
