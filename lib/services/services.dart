import 'dart:async';
import 'package:Steps4Cause/services/team.dart';
import 'package:Steps4Cause/services/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class Services with ChangeNotifier {
  final UserService userService;
  final TeamService teamService;

  Services.instance()
      : userService = new UserService.instance(),
        teamService = new TeamService() {
    userService.auth.onAuthStateChanged
        .doOnData(userService.onAuthStateChanged)
        .switchMap((u) {
      try {
        // If user does not exist in users collection then they are in a team in a sub-collection called members
        // Get the user's teamID
        teamService.getUsersTeam(u.uid).then((teamID) {
          // update the current user profile
          userService.updateCurrentUser(u, teamID);
          // notify the user service
          notifyListeners();
        });
        notifyListeners();
      } catch (Exception) {
        notifyListeners();
      }
      return null;
    }).listen((_) {}).onError((error) {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
