import 'package:CitySocial/models/user.dart';
import 'package:CitySocial/pages/activity_feed.dart';
import 'package:CitySocial/pages/profile.dart';
import 'package:CitySocial/pages/search.dart';
import 'package:CitySocial/pages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:CitySocial/pages/create_account.dart';


// import for google sign
import 'create_account.dart'; 

//enable us to use no. of methods eg. login/logout
final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();

final usersRef = Firestore.instance.collection("users");
final postsRef = Firestore.instance.collection("posts");
final commentsRef = Firestore.instance.collection("posts");
final activityFeedRef = Firestore.instance.collection("feed");
final followersRef = Firestore.instance.collection("followers");
final followingRef = Firestore.instance.collection("following");
final DateTime timestamp = DateTime.now();
// varaible to store userdata
User currentUser;

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
    //if Detect when user SignIn
    if (account != null) {
      //execute the function in fireStore
      createUserInFirestore();

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

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });
      //refetching the doc and updating
      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
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
          // Timeline(),
          RaisedButton(
            child: Text('Logout'),
            onPressed: logout,
          ),
          ActivityFeed(),
          //pass to currentUser argument
          Upload(currentUser: currentUser),
          Search(),
          //first check current user is not null and only in that case we want id of it
          Profile(profileId: currentUser?.id),
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
