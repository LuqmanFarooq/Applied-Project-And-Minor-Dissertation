import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//displaying authenticated screen for authenticated users and splash screen for unauthenticated users with the help of state
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //displaying auth screen when its false and unauth when its true
  bool isAuth = false;

  Widget buildAuthScreen() {
    return Text("Authenticated");
  }

  // return type of scafold widget with signin button created from signinpng image
  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.teal, Colors.purple],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'City Social',
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 90.0, color: Colors.white),
            ),
            GestureDetector(
              // checking if button works
              onTap: () => print("tapped"),
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
