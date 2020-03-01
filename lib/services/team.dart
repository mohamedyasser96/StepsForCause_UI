import 'package:Steps4Cause/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  String teamName;
  List users;
  int totalSteps;
  String id;

  Team({this.teamName, this.users, this.totalSteps, this.id});

  factory Team.fromMap(Map data) {
    data = data ?? {};
    return Team(
        teamName: data['teamName'] ?? '',
        users: data['users'] ?? [],
        totalSteps: data['totalSteps'] ?? 0);
  }

  void mapToTeam(Map<String, dynamic> map) {
    id = map['id'];
    teamName = map['teamName'];
    users = map['users'];
    totalSteps = map['totalSteps'];
  }

  void printTeam() {
    print("{\n" +
        "\tname: " +
        teamName.toString() +
        "\n" +
        "\ttotalSteps: " +
        totalSteps.toString() +
        "\n" +
        "\tusers: " +
        users.toString() +
        "\n" +
        "\tid: " +
        id.toString() +
        "\n" +
        "}");
  }
}

class TeamService {
  final Firestore _firestore = Firestore.instance;
  Team team = new Team();

  // The function returns a map with two variables:
  //  exists: true or false => determines whether a team with the specified team name exists or not
  //  teamRef: The document reference to the team with the specified team name if it exists
  Future<Map<String, dynamic>> _doesTeamExist(String teamName) async {
    Map<String, dynamic> res = new Map();
    Query ref =
    _firestore.collection("/teams").where('teamName', isEqualTo: teamName);

    await ref.getDocuments().then((teams) {
      if (teams.documents.length > 0) res.putIfAbsent('exists', () => true);
      teams.documents.forEach((t) {
        res.putIfAbsent('teamRef', () => t.reference);
      });
    });

    res.putIfAbsent('exists', () => false);

    return res;
  }

  Future<Team> getTeam(String teamID) async {
    print ("THE TEAM ID IS " + teamID);
    DocumentReference teamRef = _firestore.collection("/teams").document(teamID);
    List<Map<String, dynamic>> users = new List();

    await teamRef.get().then((t) {
      team.mapToTeam(t.data);
    });

    CollectionReference membersRef = _firestore.collection("/teams").document(teamID).collection("members");

    await membersRef.getDocuments().then((members) {
      members.documents.forEach((member) {
        users.add(member.data);
      });
    });

    team.users = users;

    return team;
  }

  Future<bool> addNewTeam(Profile p, String teamName) async {
    Map<String, dynamic> teamExists = await _doesTeamExist(teamName);
    Map<String, dynamic> user;

    // Check if team with specified teamName exists (teamName should be unique)
    if (teamExists['exists']) {
      return false;
    }

    // This is the reference to the user adding the team
    DocumentReference userRef = _firestore.collection("/users").document(p.id);

    CollectionReference teamsCollection = _firestore.collection("/teams");

    // Retrieve the user data
    await userRef.get().then((u) {
      if (u.exists) {
        user = u.data;
      }
    });

    int totalSteps = p.stepCount;

    // Add the team
    DocumentReference t = await teamsCollection
        .add({'teamName': teamName, 'totalSteps': totalSteps});

    user.putIfAbsent("team", () => t.documentID);

    // Create a members sub-collection
    DocumentReference userToAddRef = t.collection("members").document(p.id);
    await userToAddRef.setData(user);

    // Delete the user from users collection
    await userRef.delete();

    List<Map<String, dynamic>> members = new List();
    members.add(user);

    team.id = t.documentID;
    team.teamName = teamName;
    team.totalSteps = totalSteps;
    team.users = members;

    print ("THE TEAM IN ADD NEW TEAM ");
    team.printTeam();
    return true;
  }

  Future<bool> addUserToTeam(Profile p, String teamName) async {
    Map<String, dynamic> teamExists = await _doesTeamExist(teamName);
    Map<String, dynamic> user;
    try {
      if (!teamExists['exists'])
        return false;

      DocumentReference teamRef = teamExists['teamRef'];
      DocumentReference userRef = _firestore.collection("/users").document(
          p.id);

      await userRef.get().then((u) {
        if (u.exists) {
          user = u.data;
        }
      });

      await user.putIfAbsent("team", () => teamRef.documentID);

      DocumentReference userToAddRef = teamRef.collection("members").document(
          p.id);

      await userToAddRef.setData(user);
      await updateTeamTotal(teamRef.documentID, user['stepCount']);
      await userRef.delete();

      if (team.users == null) {
        team.users = new List();
        team.users.add(user);
      } else
        team.users.add(user);

      team.id = teamRef.documentID;
      team.teamName = teamName;

      team.printTeam();
      return true;
    } catch (Exception) {
      print ("EXCEPTION IN ADD USER TO TEAM " + Exception.toString());
    }
  }

  Future<String> getUsersTeam(String userID) async {
    String teamID;
    await _firestore
        .collectionGroup("members")
        .where('uid', isEqualTo: userID)
        .getDocuments()
        .then((docs) {
      docs.documents.forEach((t) {
        teamID = t.data['team'];
      });
    });

    return teamID;
  }

  Future<void> updateTeamTotal(String teamID, int steps) async {
    int currentSteps = 0;
    int totalSteps = 0;

    // Get current total
    await _firestore.collection("/teams").document(teamID).get().then((t) async {
      currentSteps = t.data['totalSteps'];
      // Add new steps to total
      totalSteps = currentSteps + steps;
      await _firestore
          .collection("/teams")
          .document(teamID)
          .updateData({'totalSteps': totalSteps});
      team.totalSteps = t.data['totalSteps'] + steps;
    });
  }
}
