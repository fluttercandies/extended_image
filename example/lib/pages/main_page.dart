import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:oktoast/oktoast.dart';

import '../example_route.dart';

@FFRoute(
  name: "fluttercandies://mainpage",
  routeName: "MainPage",
)
class MainPage extends StatelessWidget {
  List<RouteResult> routes;
  MainPage() {
    routeNames.remove("fluttercandies://picswiper");
    routeNames.remove("fluttercandies://mainpage");
    routes = routeNames
        .map<RouteResult>((name) => getRouteResult(name: name))
        .toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("extended image"),
      ),
      body: ListView.builder(
        itemBuilder: (c, index) {
          var page = routes[index];
          return Container(
              margin: EdgeInsets.all(20.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (index + 1).toString() + "." + page.routeName,
                      //style: TextStyle(inherit: false),
                    ),
                    Text(
                      page.description,
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, routeNames[index]);
                },
              ));
        },
        itemCount: routeNames.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ///clear memory
          clearMemoryImageCache();

          ///clear local cahced
          clearDiskCachedImages().then((bool done) {
            showToast(done ? "clear succeed" : "clear failed",
                position: ToastPosition(align: Alignment.center));
          });
        },
        child: Text(
          "clear cache",
          textAlign: TextAlign.center,
          style: TextStyle(
            inherit: false,
          ),
        ),
      ),
    );
  }
}
