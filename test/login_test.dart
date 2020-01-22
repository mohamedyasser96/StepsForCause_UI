import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driver/flutter_driver.dart';

import 'package:flutter_app/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_app/login.dart';
import 'package:flutter_app/home.dart';

void main() {
  test('Token save test', () {
    // Build our app and trigger a frame.
//    await tester.pumpWidget(myLoginPage());

    final log = myLoginPageState();
    final h = MyHomePageState();

    h.simulateToken('aaabbb');

//    log.login("moham@dell.com", "abc123");

    h.getEmail();


    expect(h.token, 'aaabbb');


  });
}