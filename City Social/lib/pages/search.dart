import 'package:CitySocial/models/user.dart';
import 'package:CitySocial/pages/home.dart';
import 'package:CitySocial/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
// to clear the text in the input field
  TextEditingController searchController = TextEditingController();

  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
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
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
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

  buildSearchResults() {
    // we are resolving our search results feature with our future builder
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          // list of text widgets
          List<Text> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            // for each user document that we get we need to deserialize it
            User user = User.fromDocument(doc);
            // wrapping into text widget and  addding the result to the searchResults list
            searchResults.add(Text(user.username));
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
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
