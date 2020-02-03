import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

enum AuthStatus { undeterminate, authenticated, unauthenticated, unverified }

class Profile {
  final String name;
  final String email;
  final int stepCount;

  Profile({this.name, this.stepCount, this.email});

  factory Profile.fromMap(Map data) {
    data = data ?? {};
    return Profile(
        name: data['name'] ?? '',
        stepCount: data['stepCount'] ?? 0,
        email: data['email'] ?? '');
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

  PublishSubject loading = PublishSubject();
  UserService.instance()
      : _auth = FirebaseAuth.instance,
        _db = FirebaseDatabase.instance {
    _subscription =
        _auth.onAuthStateChanged.doOnData(_onAuthStateChanged).switchMap((u) {
      return _db.reference().child("users").child(u.uid).onValue.map((change) {
        notifyListeners();

        return Profile.fromMap(change.snapshot.value);
      });
    }).listen((p) {
      _profile = p;
      _status = AuthStatus.authenticated;
      notifyListeners();
    });
  }

  Future<void> _onAuthStateChanged(FirebaseUser u) async {
    _user = u;
    if (u == null) {
      _status = AuthStatus.unauthenticated;
    } else if (u.isEmailVerified == false) {
      _status = AuthStatus.unverified;
    }
    notifyListeners();
  }

  // constructor

  Future<FirebaseUser> signInWithEmailandPassword(
      String email, String password) async {
    // Start
    loading.add(true);

    // Step 2
    FirebaseUser user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    // Done
    loading.add(false);
    // notifyListeners();
    print("signed in " + user.email);
    return user;
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String name, String password) async {
    loading.add(true);
    FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    await _onSignUp(user, name);
    loading.add(false);

    user.sendEmailVerification();
  }

  Future<void> _onSignUp(FirebaseUser user, String name) async {
    DatabaseReference ref = _db.reference().child("users").child(user.uid);

    var rng = new Random();

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

  void signOut() {
    _auth.signOut();
  }

  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}
