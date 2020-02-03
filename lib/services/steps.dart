import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/services/user.dart';
import 'package:pedometer/pedometer.dart';

class StepsService {
  Pedometer _pedometer;
  StreamSubscription _subscription;
  FirebaseDatabase _db;
  UserService _userService;
  StepsService.instance()
      : _pedometer = Pedometer(),
        _userService = UserService.instance() {
    _subscription = _pedometer.pedometerStream
        .listen(_onData, onError: _onError, cancelOnError: true);
  }
  void _onError(error) => print("Flutter Pedometer Error: $error");
  void _onData(int steps) {
    _userService.incrementStepCount(steps);
  }

  void dispose() {
    _subscription.cancel();
  }
}
