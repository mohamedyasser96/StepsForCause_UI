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
    List<Map<String, dynamic>> users = new List();
    Map<String, dynamic> res = new Map();

    Query ref =
        _firestore.collection("/teams").where('teamName', isEqualTo: teamName);

    // get all teams with the specified team (this should return only one
    // so there is no overhead in the loop)
    await ref.getDocuments().then((teams) {
      // if the length of the documents array is > 0, it means there is a team with the
      // specified -> it exists
      if (teams.documents.length > 0) res.putIfAbsent('exists', () => true);

      // this section populates the local copy of the team object
      teams.documents.forEach((t) async {
        res.putIfAbsent('teamRef', () => t.reference);
        CollectionReference membersRef =
        _firestore.collection("/teams").document(t.documentID).collection("members");

        await membersRef.getDocuments().then((members) {
          members.documents.forEach((member) {
            users.add(member.data);
          });
        });

        team.teamName = t.data['teamName'];
        team.totalSteps = t.data['totalSteps'];
        team.users = users;
      });
    });

    // if the key 'exists' was not placed in the returned map before, it means
    // the team does not exist
    res.putIfAbsent('exists', () => false);

    return res;
  }

  Future<Team> getTeam(String teamID) async {
    // get the team reference
    DocumentReference teamRef =
        _firestore.collection("/teams").document(teamID);
    List<Map<String, dynamic>> users = new List();

    // get the team object using the team ref and store the team object in the
    // local copy
    await teamRef.get().then((t) {
      team.mapToTeam(t.data);
    });

    // get the members sub-collection reference
    CollectionReference membersRef =
        _firestore.collection("/teams").document(teamID).collection("members");


    // get the user objects the sub-collection and store them in the local copy
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

    // store the team values
    team.id = t.documentID;
    team.teamName = teamName;
    team.totalSteps = totalSteps;
    team.users = members;

    return true;
  }

  Future<bool> addUserToTeam(Profile p, String teamName) async {
    // first check if the team exists
    Map<String, dynamic> teamExists = await _doesTeamExist(teamName);
    Map<String, dynamic> user;
    try {
      // team does not exist so return false
      if (!teamExists['exists']) return false;

      // get the team and user references
      DocumentReference teamRef = teamExists['teamRef'];
      DocumentReference userRef =
          _firestore.collection("/users").document(p.id);

      // get user object
      await userRef.get().then((u) {
        if (u.exists) {
          user = u.data;
        }
      });

      // add the team_id to the user object
      await user.putIfAbsent("team", () => teamRef.documentID);

      // add a document to members sub-collection within the team with
      // the same id the user initially entered the db with
      // this would be the id generated by the firebase authentication service
      DocumentReference userToAddRef =
          teamRef.collection("members").document(p.id);

      // update the user added in the previous step with the user object that was
      // available in the users collection
      // then update the team total
      // remove the user from the users collection
      await userToAddRef.setData(user);
      await updateTeamTotal(teamRef.documentID, user['stepCount']);
      await userRef.delete();

      // update our local copy of the team object within the code
      if (team.users == null) {
        team.users = new List();
        team.users.add(user);
      } else
        team.users.add(user);

      team.id = teamRef.documentID;
      team.teamName = teamName;

      return true;
    } catch (Exception) {
      print("EXCEPTION IN ADD USER TO TEAM " + Exception.toString());
    }
  }

  // Function to return the team id of the specified user
  // Parameters: userID -> the user we are trying to find the team of
  // Returns: String specifying the teamID
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
    int currentSteps = team.totalSteps;
    int totalSteps = 0;

    // Add new steps to total
    totalSteps = currentSteps + steps;
    // update value in firebase
    await _firestore
        .collection("/teams")
        .document(teamID)
        .updateData({'totalSteps': totalSteps});
    team.totalSteps = totalSteps;
  }
}
