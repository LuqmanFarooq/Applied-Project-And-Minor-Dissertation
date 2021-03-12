// ignore: avoid_web_libraries_in_flutter

//import 'dart:html';

import 'package:CitySocial/models/user.dart';
import 'package:CitySocial/pages/home.dart';
import 'package:CitySocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'activity_feed.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
// to clear the text in the input field
  TextEditingController searchController = TextEditingController();

  Future<QuerySnapshot> searchResultsFuture;
// created handleSearch funtion going to take userRef from home after import
  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        //execute string query
        .where("displayName", isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

// this function take searchController and call clear method on it to clear the input field
  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search a User...",
          //togive it gray background setting filled to true
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        //function  associated with onFieldSubmitted when formFieldSubmitted with given text typed in to it
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    // for resizing the image in the horizontal orientation of the device
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        //resizable widget that resizes when keyboard opens up and removes overflow error and supports scrolling
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            )
          ],
        ),
      ),
    );
  }

//execute buildSearchResult which passes searchResultsFuture
  buildSearchResults() {
    // we are resolving our search results feature with our future builder
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          //doucuments into list of text widgets
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            // for each user document that we get we need to deserialize it
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(user);
            // wrapping into text widget and  addding the result to the searchResults list
            searchResults.add(searchResult);
          });
          // returning listview with its chidren being our search results
          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

// this class is for showing the results that come back from a given search
class UserResult extends StatelessWidget {
  //to accept user varaiable to UserResult
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    //insted of text widget retur conatiner with its own properties
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            //onTap can be used as userProfile page when created
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                //used CachedNetworkImagedProvider instead of NetworkImage widget to save and display
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          //divider from the above single result to multiple result from search incase
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
