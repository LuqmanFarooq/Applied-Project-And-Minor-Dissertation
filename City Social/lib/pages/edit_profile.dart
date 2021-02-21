import 'package:CitySocial/models/user.dart';
import 'package:CitySocial/pages/home.dart';
import 'package:CitySocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

class EditProfile extends StatefulWidget {
  final String currentUserId;

// passing to our editprofile constructor
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
// to show loading spinner upon loading state initially flase will set to true when we begin fetching data
  bool isLoading = false;
  // declaring var user in state
  User user;
  // controller for displayname
  TextEditingController displayNameController = TextEditingController();
  // controller for bio
  TextEditingController bioController = TextEditingController();
  bool displayNameValid = true;
  bool bioValid = true;
  final scaffoleKey = GlobalKey<ScaffoldState>();

// fetching currentuser details on state initialization
  @override
  void initState() {
    super.initState();

    getUser();
  }

// function responsible for getting user details
  getUser() async {
    setState(() {
      isLoading = true;
    });
// putting the result in a variable of type document snapshot called doc
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
// deserialize the document using the user model and put in a variable called user
    user = User.fromDocument(doc);
    // setting Text controllers
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

// returns column widget
  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Change Display Name",
            errorText: displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Bio",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Change Bio",
            errorText: bioValid ? null : "Bio is too long",
          ),
        )
      ],
    );
  }

// conditionally set the displaynamefield and bio field
  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 5 ||
              displayNameController.text.isEmpty
          ? displayNameValid = false
          : displayNameValid = true;
      bioController.text.trim().length > 100
          ? bioValid = false
          : bioValid = true;
    });
    // only if display name is valid and bio is valid then we will update profile data
    if (displayNameValid && bioValid) {
      usersRef.document(widget.currentUserId).updateData({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      SnackBar snackBar =
          SnackBar(content: Text("Profile Updated Sucessfully!"));
      scaffoleKey.currentState.showSnackBar(snackBar);
    }
  }

// performs logout
  logout() async {
    await googleSignIn.signOut();
    // to ensure user cannt edit any more info on this page we move to home page
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    // building appbar and body of EditProfile
    return Scaffold(
        // for snackbar to let user know profile updated
        key: scaffoleKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          // for displaying icon button
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.done,
                size: 30.0,
                color: Colors.green,
              ),
            ),
          ],
        ),
        // for body
        body: isLoading
            ? circularProgress()
            : ListView(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              buildDisplayNameField(),
                              buildBioField(),
                            ],
                          ),
                        ),
                        RaisedButton(
                          onPressed: updateProfileData,
                          child: Text(
                            "Update Profile",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: FlatButton.icon(
                            onPressed: logout,
                            icon: Icon(Icons.cancel, color: Colors.red),
                            label: Text(
                              "Logout",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ));
  }
}
