import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';// import for google sign

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

//active listener to check user signIn, with firebase using google signIn.. 
  @override
  void initState() { 
    super.initState();
    
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
      
      //or  error in authentication 
     }, onError:  (err) {
       print('Error Siging in : $err');
     });
     //Reauthinticate user when app is open and resolve future 
     googleSignIn.signInSilently(suppressErrors: false ).then((account) {
       handleSignIn(account);

     }).catchError((err){
       print('Error Siging in : $err');
     });
  } 
  handleSignIn(GoogleSignInAccount account){
    //if Detect when user Signed 
      if(account != null ) {
        print('User Signed in!: $account');
        setState(() {
          isAuth = true;
        });
        //else  detect when user Signed out
      }else{
          setState(() {
          isAuth = false;
          });
      }
    
  }

  //navigate loginPage
   login() {
    googleSignIn.signIn();
  }
//navigate login
  logout() {
    googleSignIn.signOut();
  }

 Widget buildAuthScreen() {
    return RaisedButton(
      child: Text('Logout'),
      onPressed: logout,
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
