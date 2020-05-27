import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:oktoast/oktoast.dart';

import '../example_route.dart';
import '../example_routes.dart' as example_routes;

@FFRoute(
  name: 'fluttercandies://mainpage',
  routeName: 'MainPage',
)
class MainPage extends StatelessWidget {
  MainPage() {
    routeNames.addAll(example_routes.routeNames);
    routeNames.remove('fluttercandies://picswiper');
    routeNames.remove('fluttercandies://mainpage');
    routes.addAll(routeNames
        .map<RouteResult>((String name) => getRouteResult(name: name)));
  }
  final List<RouteResult> routes = <RouteResult>[];
  final List<String> routeNames=<String>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('ExtendedImage'),
        actions: <Widget>[
          ButtonTheme(
            minWidth: 0.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: FlatButton(
              child: Text(
                'Github',
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                launch('https://github.com/fluttercandies/extended_image');
              },
            ),
          ),
          ButtonTheme(
            padding: const EdgeInsets.only(right: 10.0),
            minWidth: 0.0,
            child: FlatButton(
              child:
                  Image.network('https://pub.idqqimg.com/wpa/images/group.png'),
              onPressed: () {
                launch('https://jq.qq.com/?_wv=1027&k=5bcc0gy');
              },
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          final RouteResult page = routes[index];
          return Container(
              margin: const EdgeInsets.all(20.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (index + 1).toString() + '.' + page.routeName,
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
        itemCount: routes.length,
      ),
      floatingActionButton: kIsWeb
          ? null
          : FloatingActionButton(
              onPressed: () {
                ///clear memory
                clearMemoryImageCache();

                ///clear local cahced
                clearDiskCachedImages().then((bool done) {
                  showToast(done ? 'clear succeed' : 'clear failed',
                      position: const ToastPosition(align: Alignment.center));
                });
              },
              child: const Text(
                'clear cache',
                textAlign: TextAlign.center,
                style: TextStyle(
                  inherit: false,
                ),
              ),
            ),
    );
  }
}
