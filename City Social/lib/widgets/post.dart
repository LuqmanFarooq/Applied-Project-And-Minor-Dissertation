import 'package:CitySocial/models/user.dart';
import 'package:CitySocial/pages/home.dart';
import 'package:CitySocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

// checking the likes map of firestore and counting the number of true values for likes
  int getLikesCount(likes) {
    // if no likes return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is expplicitly set to true add a like count
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likesCount: getLikesCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  // as likes are gonna be updated so setting it to a map
  Map likes;
  int likesCount;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likesCount,
  });

  buildPostHeader() {
    // as we want to get post owners data so using future builder for that
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        // deserializing data
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          // if someone taps on an username we want to show their profile
          title: GestureDetector(
            onTap: () => print('will show profile'),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          // to delete the post
          trailing: IconButton(
            onPressed: () => print('delete post'),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  } // postheaderfunction

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print('like post'),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(mediaUrl),
        ],
      ),
    );
  } // buildpostimage

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => print('like post'),
              child: Icon(
                Icons.favorite_border,
                size: 28.0,
                color: Colors.red[800],
              ),
            ),
            //to separate likes and comments buttons
            Padding(padding: EdgeInsets.only(right: 20)),
            GestureDetector(
              onTap: () => print('show comments'),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                // to interpolate the number of likes
                "$likesCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                // to interpolate the number of likes
                "$username  ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // description of the user who made that post next to username
            Expanded(child: Text(description))
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
