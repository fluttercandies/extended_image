import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'example_route.dart';
import 'example_route_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    if (!kIsWeb) {
      clearDiskCachedImages(duration: const Duration(days: 7));
    }
    listSourceRepository.loadData().then((bool result) {
      if (listSourceRepository.isNotEmpty) {
        _imageTestUrl = listSourceRepository.first.imageUrl;
      }
    });
  }
  final TuChongRepository listSourceRepository = TuChongRepository();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      title: 'extended image demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (BuildContext c, Widget w) {
        ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);
        // ScreenUtil.instance =
        //     ScreenUtil(width: 750, height: 1334, allowFontScaling: true)
        //       ..init(c);
        if (!kIsWeb) {
          final MediaQueryData data = MediaQuery.of(c);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: w,
          );
        }
        return w;
      },
      initialRoute: 'fluttercandies://mainpage',
      onGenerateRoute: (RouteSettings settings) {
        String routeName = settings.name;
        //when refresh web, route will as following
        //   /
        //   /fluttercandies:
        //   /fluttercandies:/
        //   /fluttercandies://mainpage

        if (kIsWeb && routeName.startsWith('/')) {
          routeName = routeName.replaceFirst('/', '');
        }

        final RouteResult routeResult = getRouteResult(
            name: routeName,
            arguments: settings.arguments as Map<String, dynamic>);

        if (routeResult.showStatusBar != null ||
            routeResult.routeName != null) {
          settings = FFRouteSettings(
              arguments: settings.arguments,
              name: routeName,
              routeName: routeResult.routeName,
              showStatusBar: routeResult.showStatusBar);
        }

        final Widget page = routeResult.widget ??
            getRouteResult(
                    name: 'fluttercandies://mainpage',
                    arguments: settings.arguments as Map<String, dynamic>)
                .widget;

        final TargetPlatform platform = Theme.of(context).platform;
        switch (routeResult.pageRouteType) {
          case PageRouteType.material:
            return MaterialPageRoute<void>(
                settings: settings, builder: (BuildContext c) => page);
          case PageRouteType.cupertino:
            return CupertinoPageRoute<void>(
                settings: settings, builder: (BuildContext c) => page);
          case PageRouteType.transparent:
            return platform == TargetPlatform.iOS
                ? TransparentCupertinoPageRoute<void>(
                    settings: settings, builder: (BuildContext c) => page)
                : TransparentMaterialPageRoute<void>(
                    settings: settings, builder: (BuildContext c) => page);
//            return FFTransparentPageRoute(
//                settings: settings,
//                pageBuilder: (BuildContext context, Animation<double> animation,
//                        Animation<double> secondaryAnimation) =>
//                    page);
          default:
            return platform == TargetPlatform.iOS
                ? CupertinoPageRoute<void>(
                    settings: settings, builder: (BuildContext c) => page)
                : MaterialPageRoute<void>(
                    settings: settings, builder: (BuildContext c) => page);
        }
      },
    ));
  }
}

String _imageTestUrl;
String get imageTestUrl =>
    _imageTestUrl ?? 'https://photo.tuchong.com/4870004/f/298584322.jpg';
