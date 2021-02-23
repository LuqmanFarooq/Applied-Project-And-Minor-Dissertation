import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

//  to make image fade into place when it loads and display a loading spinner
Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    // to display a loading spinner while image is loading
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      // to center the circular widget with in the image
      padding: EdgeInsets.all(20.0),
    ),
    // in the event when image dowsnt load
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
