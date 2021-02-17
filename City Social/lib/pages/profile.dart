import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:CitySocial/models/user.dart';
import 'package:CitySocial/pages/home.dart';
import 'package:CitySocial/widgets/header.dart';
import 'package:CitySocial/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;
//get profile user information by passing user id in this class and fetching user database onit through home page 
  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  buildProfileButton() {
    return Text("profile button");
  }
  //header
  buildProfileHeader() {
    //enable us to resolve future user info based on id using userRef from home
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        //if dont have any data
        if (!snapshot.hasData) {
          return circularProgress();
        }
        //deserialize document available on snapShot.data(import userModel)
        User user = User.fromDocument(snapshot.data);
        return Padding(
          //set padding on all side using edgeInsets
          padding: EdgeInsets.all(16.0),
          //parent column wideget with its children
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  //user avatar on leftTop
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  //on the right another column with its children (post,followers,following)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("posts", 0),
                            buildCountColumn("followers", 0),
                            buildCountColumn("following", 0),
                          ],
                        ),
                        //for edit porfile button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                //for user name below avatar on leftop
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //for user bio below userName on leftop
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[buildProfileHeader()],
      ),
    );
  }
}
