import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

enum AuthStatus { undeterminate, authenticated, unauthenticated, unverified }

class Profile {
  String name;
  String email;
  int stepCount;
  bool isloggedIn;
  var photo;
  String team;

  Profile({this.name, this.stepCount, this.email, this.photo, this.team});

  factory Profile.fromMap(Map data) {
    data = data ?? {};
    return Profile(
        name: data['name'] ?? '',
        stepCount: data['stepCount'] ?? 0,
        email: data['email'] ?? '',
        photo: data['photo'] ?? '',
        team: data['team'] ?? '');
  }

  void mapToProfile(Map map) {
    name = map.values.elementAt(3);
    email = map.values.elementAt(0);
    stepCount = map.values.elementAt(1);
    photo = map.values.elementAt(4);
    isloggedIn = false;
  }
}

class Team {
  String teamName;
  List users;
  int totalSteps;

  Team({this.teamName, this.users, this.totalSteps});

  factory Team.fromMap(Map data) {
    data = data ?? {};
    return Team(
        teamName: data['teamName'] ?? '',
        users: data['users'] ?? [],
        totalSteps: data['totalSteps'] ?? 0);
  }

  void mapToTeam(Map<String, dynamic> map) {
    teamName = map.values.elementAt(0);
    users = map.values.elementAt(2);
    totalSteps = map.values.elementAt(1);
  }

  // getTeams() {
  //   teamList = _db
  //       .reference()
  //       .child("teams")
  //       .onValue
  //       .map((change) {
  //     var v = Map<String, Map>.from(change.snapshot.value);
  //     final List<TeamMember> datalist = [];
  //     v.forEach((key, value) {
  //       datalist.add(TeamMember.fromMap(value));
  //     });
  //     datalist.sort((a, b) => b.stepCount - a.stepCount);
  //     print(datalist);
  //     print(v);
  //     return datalist;
  //   });
  // }
}

class UserService with ChangeNotifier {
  // Dependencies
  final FirebaseAuth _auth;
  final FirebaseDatabase _db;

  // Shared State for Widgets
  bool checkTeamName;
  Profile _profile; // custom user data in Firestore
  FirebaseUser _user; // custom user data in Firestore
  var team;
  Team teamData;
  AuthStatus _status = AuthStatus.undeterminate;
  AuthStatus get status => _status;
  Profile get user => _profile;
  StreamSubscription _subscription;
  Set teamMembers = {};
  int teamTotal;

  UserService.instance()
      : _auth = FirebaseAuth.instance,
        _db = FirebaseDatabase.instance {
    _subscription =
        _auth.onAuthStateChanged.doOnData(_onAuthStateChanged).switchMap((u) {
      return _db.reference().child("users").child(u.uid).onValue.map((change) {
        final profile = Profile.fromMap(change.snapshot.value);
        _profile = profile;
        _profile.mapToProfile(Map<String, dynamic>.from(change.snapshot.value));
        if (u.isEmailVerified && profile != null) {
          _status = AuthStatus.authenticated;
          getTeamData(profile.team);
          notifyListeners();
        }
      });
    }).listen((_) {});
  }

  Future<void> _onAuthStateChanged(FirebaseUser u) async {
    _user = u;
    if (u == null) {
      _status = AuthStatus.unauthenticated;
    } else if (u.isEmailVerified == false) {
      _status = AuthStatus.unverified;
    } else {
      _status = AuthStatus.undeterminate;
    }
    notifyListeners();
  }

  // constructor

  Future<FirebaseUser> signInWithEmailandPassword(
      String email, String password) async {
    // Start

    // Step 2
    FirebaseUser user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    // Done

    print("signed in " + user.email);
    try {
      _profile.isloggedIn = true;
    } catch (Exception) {
      print(
          "EXCEPTION WHEN SETTING PROFILE.ISLOGGEDIN " + Exception.toString());
    }
    return user;
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String name, String password, var photo) async {
    FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    await _onSignUp(user, name, photo);
    await user.sendEmailVerification();
  }

  Future<void> _onSignUp(FirebaseUser user, String name, var photo) async {
    DatabaseReference ref = _db.reference().child("users").child(user.uid);

    return ref.update({
      'uid': user.uid,
      'email': user.email,
      'stepCount': 0,
      'name': name,
      'photo': photo
    });
  }

  Future<void> incrementStepCount(int steps) {
    final count = _profile.stepCount + steps;
    if (user != null) {
      DatabaseReference ref = _db.reference().child("users").child(_user.uid);
      return ref.update({'stepCount': count});
    } else
      return null;
  }

  Future<void> getTeamByName(String name) async {
    final exists = await _db
        .reference()
        .child('teams')
        .reference()
        .orderByChild("teamName")
        .equalTo(name)
        .limitToLast(1)
        .once();
    if (exists.value != null) {
      team = exists.value;
      final t = Team.fromMap(Map.from(exists.value).values.toList()[0]);
      teamData = t;

      print(teamData.users);
      checkTeamName = true;
    } else
      checkTeamName = false;
  }

  // Future<bool> checkTeamName(String name) async {
  //   bool flag = false;
  //   getTeamByName(name);
  //   if (team != null) flag = true;

  //   return flag;
  // }

  Future<bool> addNewTeam(Profile p, String teamName) async {
    await getTeamByName(teamName);
    var list = [];
    list.add(_user.uid);
    if (!checkTeamName && p != null) {
      DatabaseReference ref = _db.reference().child("teams").push();
      DatabaseReference uref = _db.reference().child("users").child(_user.uid);
      try {
        ref.update({'teamName': teamName, 'users': list});

        uref.update({'team': teamName});
        return true;
      } catch (err) {
        return false;
      }
    } else
      return false;
  }

  Future<bool> addToExistingTeam(Profile p, String teamName) async {
    await getTeamByName(teamName);
    if (checkTeamName) {
      print(team);
      var tempList = new List.from(teamData.users);
      print(tempList);
      tempList.add(_user.uid);
      DatabaseReference ref =
          _db.reference().child("teams").child(Map.from(team).keys.first);
      DatabaseReference uref = _db.reference().child("users").child(_user.uid);
      uref.update({'team': teamName});
      ref.update({
        'users': tempList,
      });
      return true;
    } else
      return false;
  }

  Future<void> getTeamData(String teamName) async {
//    teamMembers = [];
    final exists = await _db
        .reference()
        .child('users')
        .reference()
        .orderByChild("team")
        .equalTo(teamName)
        .once();
    if (exists.value != null && teamMembers.isEmpty) {
      int total = 0;
      var v = Map.from(exists.value);
      v.forEach((key, value) {
        var m = Map.from(value);
        teamMembers.add(m);
        total += m['stepCount'];
      });
      teamTotal = total;
    }
  }

  Future<int> getTeamTotalSteps(String teamName) {
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  Future<AuthStatus> isCurrentUserVerified() async {
    FirebaseUser user = await _auth.currentUser();
    try {
      try {
        user.reload();
      } catch (Exception) {
        // print("USER.RELOAD() EXCEPTION " + Exception.toString());
        _status = AuthStatus.unauthenticated;
      }
      if (user == null) {
        // print("USER IS NULL");
        _status = AuthStatus.unauthenticated;
      } else if (!user.isEmailVerified) {
        // print("USER EMAIL NOT VERIFIED");
        _status = AuthStatus.unverified;
      } else if (user.isEmailVerified && _profile.isloggedIn) {
        // print("USER EMAIL VERIFIED");
        _status = AuthStatus.authenticated;
      }
    } catch (Exception) {
      // print("EXCEPTION " + Exception.toString());
      _status = AuthStatus.undeterminate;
    }
    // print("STATUS BEFORE RETURN " + _status.toString());
    return _status;
  }
}
