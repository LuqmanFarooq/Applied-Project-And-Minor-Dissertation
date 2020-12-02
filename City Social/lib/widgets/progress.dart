import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    // centre it in both directions horizontally and vertically
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    // for circular progress indicator spinning
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}

Container linearProgress() {
  return Container(
    // here we are setting padding on just the bottomn
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}
