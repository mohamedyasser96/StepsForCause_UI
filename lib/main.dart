import 'package:flutter/material.dart';
import 'package:Steps4Cause/home.dart';
import 'package:Steps4Cause/landing.dart';
import 'package:Steps4Cause/services/user.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserService>(
      create: (context) => UserService.instance(),
      child: MaterialApp(
          home: Consumer<UserService>(builder: (context, userService, __) {
        return Splash();
      })),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 2,
        navigateAfterSeconds: new StartupWidget(),
        title: new Text(
          'Steps for Cause',
          style: new TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
        ),
        // image: new Image.asset('assets/zayed.jpg'),
        imageBackground: AssetImage('assets/zayed.jpg'),
        // backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Flutter Egypt"),
        loaderColor: Colors.red);
  }
}

class StartupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    return new FutureBuilder(
        future: userService.isDeviceRooted(),
        builder: (BuildContext contextRoot, AsyncSnapshot snapshotRoot) {
          /******************** This is where we check if the device is rooted. ************************
           * ****************** All emulators are rooted by default so comment  ************************
           * ****************** out the if else statement **********************************************
           */
          if (snapshotRoot.hasData) {
            if (!snapshotRoot.data) {
              print("DEVICE IS NOT ROOTED");
              return new FutureBuilder(
                  future: userService.isCurrentUserVerified(),
                  initialData: AuthStatus.undeterminate,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    // print("ERROR " + snapshot.error.toString());
                    // print("SNAPSHOT " + snapshot.data.toString());
                    switch (snapshot.data) {
                      case AuthStatus.authenticated:
                        return MyHomePage();
                        break;
                      case AuthStatus.undeterminate:
                        return LoadingWidget();
                      default:
                        return MyLandingPage();
                    }
                  });
            } else {
              return DialogWidget();
            }
          }
         return Container();
        },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          new CircularProgressIndicator(),
          new Text("Loading"),
        ],
      ),
    ));
  }
}

class DialogWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text("DEVICE ROOTED"),
      content: new Text("Cannot access the application as long as your device is rooted."),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        new FlatButton(
          child: new Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

void main() => runApp(MyApp());
