import 'package:CitySocial/pages/activity_feed.dart';
import 'package:CitySocial/pages/profile.dart';
import 'package:CitySocial/pages/search.dart';
import 'package:CitySocial/pages/timeline.dart';
import 'package:CitySocial/pages/upload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // import for google sign

//enable us to use no. of methods eg. login/logout
final GoogleSignIn googleSignIn = GoogleSignIn();

//displaying authenticated screen for authenticated users and splash screen for unauthenticated users with the help of state
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //displaying auth screen when its false and unauth when its true
  bool isAuth = false;
  // page controller varaiable of type PageController
  PageController pageController;
  // page index variable
  int pageIndex = 0;

//active listener to check user signIn, with firebase using google signIn..
  @override
  void initState() {
    super.initState();
    // initializing a special widget called pageController
    pageController = PageController();
    // detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);

      //or  error in authentication
    }, onError: (err) {
      print('Error Siging in : $err');
    });
    //Reauthinticate user when app is open and resolve future
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error Siging in : $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    //if Detect when user Signed
    if (account != null) {
      print('User Signed in!: $account');
      setState(() {
        isAuth = true;
      });
      //else  detect when user Signed out
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  @override
  void dispose() {
    // disposing the controller when we are no on the hone page and we dont need it
    pageController.dispose();
    super.dispose();
  }

  //navigate loginPage
  login() {
    googleSignIn.signIn();
  }

//navigate login
  logout() {
    googleSignIn.signOut();
  }

  // onPage changed Method
  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }
// onTap function responsible for changing the page in pageview
  onTap(int pageIndex) {
    pageController.animateToPage( 
      pageIndex,
      //duration parameter
      duration: Duration(milliseconds: 300),
      //in curve argument easeInOut for A cubic animation curve that starts slowly, speeds up, and then ends slowly.
      curve: Curves.easeInOut, 
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        // building a navigation bar with buttons
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
        // adding a controller which enables us to switch between controller
        controller: pageController,
        onPageChanged: onPageChanged,
        physics:
            NeverScrollableScrollPhysics(), // because we dont want page view itself to scroll
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ], // providing icons so user can click on to switch page
      ),
    );
    /*return RaisedButton(
      child: Text('Logout'),
      onPressed: logout,
    );*/
  }

  // return type of scafold widget with signin button created from signinpng image
  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
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
              onTap: login,
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
