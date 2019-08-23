import 'package:flutter/material.dart';

class NoRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("can't find route"),
        ),
        body: Center(
          child: Container(
            child: Text("can't find route"),
          ),
        ));
  }
}
