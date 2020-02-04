import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

enum AuthStatus { undeterminate, authenticated, unauthenticated, unverified }

class Profile {
  String name;
  String email;
  int stepCount;
  bool isloggedIn;

  Profile({this.name, this.stepCount, this.email});

  factory Profile.fromMap(Map data) {
    data = data ?? {};
    return Profile(
        name: data['name'] ?? '',
        stepCount: data['stepCount'] ?? 0,
        email: data['email'] ?? '');
  }

  void mapToProfile(Map<String, dynamic> map) {
    name = map.values.elementAt(3);
    email = map.values.elementAt(0);
    stepCount = map.values.elementAt(1);
    isloggedIn = false;
  }
}

class UserService with ChangeNotifier {
  // Dependencies
  final FirebaseAuth _auth;
  final FirebaseDatabase _db;

  // Shared State for Widgets

  Profile _profile; // custom user data in Firestore
  FirebaseUser _user; // custom user data in Firestore
  AuthStatus _status = AuthStatus.undeterminate;
  AuthStatus get status => _status;
  Profile get user => _profile;
  StreamSubscription _subscription;

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
    _profile.isloggedIn = true;
    return user;
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String name, String password) async {
    FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    await _onSignUp(user, name);
    await user.sendEmailVerification();
  }

  Future<void> _onSignUp(FirebaseUser user, String name) async {
    DatabaseReference ref = _db.reference().child("users").child(user.uid);

    return ref.update({
      'uid': user.uid,
      'email': user.email,
      'stepCount': 0,
      'name': name,
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
        print ("USER.RELOAD() EXCEPTION " + Exception.toString());
        _status = AuthStatus.unauthenticated;
      }
      if (user == null) {
        print("USER IS NULL");
        _status = AuthStatus.unauthenticated;
      } else if (!user.isEmailVerified) {
        print("USER EMAIL NOT VERIFIED");
        _status = AuthStatus.unverified;
      } else if (user.isEmailVerified && _profile.isloggedIn) {
        print("USER EMAIL VERIFIED");
        _status = AuthStatus.authenticated;
      }
    } catch (Exception) {
      print("EXCEPTION " + Exception.toString());
      _status = AuthStatus.undeterminate;
    }
    print("STATUS BEFORE RETURN " + _status.toString());
    return _status;
  }
}
