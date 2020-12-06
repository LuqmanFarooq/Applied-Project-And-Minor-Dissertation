import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitile = false, String titleText, bool isAppTitle}) {
  return AppBar(
    title: Text(
      // shows the title text as app name if its true otherwise displays title text
      isAppTitile ? "City Social" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitile ? "signatra" : "",
        fontSize: isAppTitile ? 50.0 : 22.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
