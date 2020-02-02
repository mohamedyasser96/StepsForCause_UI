import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

enum AuthStatus { undeterminate, authenticated, unauthenticated }

class Profile {
  final String name;
  final String email;
  final int stepCount;
  String verificationCode;
  bool isVerified;

  Profile({this.name, this.stepCount, this.email});

  factory Profile.fromMap(Map data) {
    data = data ?? {};
    return Profile(
        name: data['name'] ?? '',
        stepCount: data['stepCount'] ?? 0,
        email: data['email'] ?? '');
  }
}

class UserService {
  // Dependencies
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Shared State for Widgets
  Stream<FirebaseUser> user; // firebase user
  Stream<Profile> profile; // custom user data in Firestore
  Stream<AuthStatus> status;

  PublishSubject loading = PublishSubject();

  // constructor
  UserService() {
    loading.add(true);
    user = _auth.onAuthStateChanged;
    status = BehaviorSubject.seeded(AuthStatus.undeterminate).switchMap((s) {
      return user.map((u) {
        return u != null && u.isEmailVerified
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
      });
    });
    profile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db
            .reference()
            .child("users")
            .child(u.uid)
            .onValue
            .map((change) {
          return Profile.fromMap(change.snapshot.value);
        });
      } else {
        return Stream.empty();
      }
    });
  }

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

  Future<void> updateStepCount(FirebaseUser user, int count){
    if(user != null){
      DatabaseReference ref = _db.reference().child("users").child(user.uid);
      return ref.update({
        'stepCount': count
      });
    }
    else
      return null;

  }

  void signOut() {
    _auth.signOut();
  }
}

final UserService userService = UserService();
