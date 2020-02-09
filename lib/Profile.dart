import 'dart:convert';
import 'dart:io';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:Steps4Cause/services/steps.dart';
import 'package:Steps4Cause/services/user.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:path_provider/path_provider.dart';

class MyProfilePage extends StatelessWidget {
  final style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final start = true;
  final primaryColor = const Color(0xFF151026);

//  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: choices.length,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(75.0),
            child: AppBar(
                backgroundColor: primaryColor,
                bottom: TabBar(
                  isScrollable: true,
                  tabs: choices.map((Choice choice) {
                    return Tab(
                      text: choice.title,
                      icon: Icon(choice.icon),
                    );
                  }).toList(),
                ))),
        body: TabBarView(
          children: choices.map((Choice choice) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ChoiceCard(choice: choice),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Individual', icon: Icons.assignment_ind),
  const Choice(title: 'Team', icon: Icons.group),
];

class ChoiceCard extends StatelessWidget {
  ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    // getfile();
    final quotes = [
      '“The miracle isn’t that I finished. The miracle is that I had the courage to start.” – John Bingham',
      "“You must do the thing you think you cannot do.”— Eleanor Roosevelt",
      "“Don’t dream of winning, train for it!” — Mo Farah",
      "“Running allows me to set my mind free. Nothing seems impossible. Nothing unattainable.” — Kara Goucher"
    ];

    final userService = Provider.of<UserService>(context);
    if (choice.title == 'Individual') {
      StepsService(userService: userService);

      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: ListView(
              children: <Widget>[
                new Container(
                  color: Colors.white,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new CircularPercentIndicator(
                        radius: 120.0,
                        lineWidth: 5.0,
                        percent: 0.15,
                        center: new Text("15%"),
                        progressColor: Colors.green,
                        header: new Text("Your contribution out of total"),
                      ),
                      myWidget(
                          userService.user.stepCount.toString() + " Steps"),
                      CarouselSlider(
                        height: 450.0,
                        items: quotes.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  child: Text(
                                    ' $i',
                                    style: TextStyle(fontSize: 18.0),
                                  ));
                            },
                          );
                        }).toList(),
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 30),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        viewportFraction: 1.0,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else
      return Card(color: Colors.white, child: _myListView(context));
  }
}

getfile() async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;

  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;

  String filePath = '${appDocDir.path}/quotes.text';

  new File(filePath).readAsString().then((String contents) {
    print(contents);
  });
}

Widget myWidget(t) {
  final txtColor = const Color(0xFF151026);
  return Container(
    margin: const EdgeInsets.all(30.0),
    padding: const EdgeInsets.all(10.0),
    decoration: myBoxDecoration(),
    child: Text(
      t,
      style: TextStyle(fontSize: 30.0, color: txtColor),
    ),
  );
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border.all(),
    borderRadius: BorderRadius.circular(10.0),
  );
}

Widget _myListView(BuildContext context) {
  void _showDialog(head, txt) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(head),
          content: new Text(txt),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  final userService = Provider.of<UserService>(context);
  if (userService.user.team == '') {
    TextStyle style = TextStyle(
        fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.black);

    final tnController = TextEditingController();
    final teamNameField = TextField(
      controller: tnController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Team Name",
          hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: const BorderSide(color: Colors.black))),
    );
    final registerButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            try {
              if (userService.addNewTeam(userService.user, tnController.text) !=
                  null) {
              } else {
                throw ('taken');
              }
            } catch (err) {
              _showDialog("Oops!",
                  "Team Name already taken, are you sure you are not joining?");
            }
          },
          child: Text("Register New Team",
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ));
    final joinButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            try {
              userService.addToExistingTeam(
                  userService.user, tnController.text);
            } catch (err) {
              _showDialog("Oops!",
                  "Team Name does not exist taken, are you sure you are not creating a new team?");
            }
          },
          child: Text("Join Team",
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ));

    return Container(
      child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: ListView(children: <Widget>[
            SizedBox(height: 20.0),
            teamNameField,
            SizedBox(height: 20.0),
            registerButton,
            SizedBox(height: 20.0),
            joinButton,
          ])),
    );
  } else
    return ListView(
      children: <Widget>[
        ListTile(
          leading: new CircularPercentIndicator(
            radius: 50.0,
            // lineWidth: 5.0,
            percent: 0.096,
            center: new Text("10%"),
            progressColor: Colors.blue,
          ),
          title: Text('Mostafa Henna'),
          subtitle: Text("81 Steps"),
        ),
        ListTile(
          leading: new CircularPercentIndicator(
            radius: 50.0,
            // lineWidth: 5.0,
            percent: 0.169,
            center: new Text("17%"),
            progressColor: Colors.blue,
          ),
          title: Text('Ahmed Osama'),
          subtitle: Text("141 Steps"),
        ),
        ListTile(
          leading: new CircularPercentIndicator(
            radius: 50.0,
            // lineWidth: 5.0,
            percent: 0.21,
            center: new Text("21%"),
            progressColor: Colors.blue,
          ),
          title: Text('Omar Abdulaal'),
          subtitle: Text("175 Steps"),
        ),
        ListTile(
          leading: new CircularPercentIndicator(
            radius: 50.0,
            // lineWidth: 5.0,
            percent: 0.526,
            center: new Text("53%"),
            progressColor: Colors.blue,
          ),
          title: Text('You'),
          subtitle: Text('441 Steps'),
        ),
        Padding(
            padding: const EdgeInsets.all(100.0),
            child: CircularPercentIndicator(
              radius: 100.0,
              // lineWidth: 5.0,
              percent: 0.23,
              center: new Text("23%"),
              progressColor: Colors.green,
              header: Text("Team Total Contribution: 838 Steps"),
            ))
      ],
    );
}
