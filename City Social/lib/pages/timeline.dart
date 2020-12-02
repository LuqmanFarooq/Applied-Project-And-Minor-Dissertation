import 'package:CitySocial/widgets/header.dart';
import 'package:CitySocial/widgets/progress.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      // for app bar we are using aur header widget located in widgets folder
      appBar: header(context, isAppTitile: true),
      body: circularProgress(),
    );
  }
}
