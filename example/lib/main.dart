import 'dart:io';

import 'package:example/common/tu_chong_repository.dart';
import 'package:example/pages/custom_image_demo.dart';
import 'package:example/pages/crop_image_demo.dart';
import 'package:example/pages/image_demo.dart';
import 'package:example/pages/image_list_demo.dart';
import 'package:example/pages/no_route.dart';
import 'package:example/pages/paint_image_demo.dart';
import 'package:example/pages/photo_view_demo.dart';
import 'package:example/pages/zoom_image_demo.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import "package:oktoast/oktoast.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:example/pages/image_editor_demo.dart';

import 'example_route.dart';
import 'example_route_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final TuChongRepository listSourceRepository = TuChongRepository();
  MyApp() {
    clearDiskCachedImages(duration: Duration(days: 7));
    listSourceRepository.loadData().then((result) {
      if (listSourceRepository.length > 0)
        _imageTestUrl = listSourceRepository.first.imageUrl;
    });
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        FFNavigatorObserver(routeChange: (name) {
          //you can track page here
          // print(name);
        }, showStatusBarChange: (bool showStatusBar) {
          if (showStatusBar) {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
          } else {
            SystemChrome.setEnabledSystemUIOverlays([]);
          }
        })
      ],
      builder: (c, w) {
        ScreenUtil.instance =
            ScreenUtil(width: 750, height: 1334, allowFontScaling: true)
              ..init(c);
        var data = MediaQuery.of(c);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: w,
        );
      },
      initialRoute: "fluttercandies://mainpage",
      onGenerateRoute: (RouteSettings settings) {
        var routeResult =
            getRouteResult(name: settings.name, arguments: settings.arguments);

        if (routeResult.showStatusBar != null ||
            routeResult.routeName != null) {
          settings = FFRouteSettings(
              arguments: settings.arguments,
              name: settings.name,
              isInitialRoute: settings.isInitialRoute,
              routeName: routeResult.routeName,
              showStatusBar: routeResult.showStatusBar);
        }

        var page = routeResult.widget ?? NoRoute();

        switch (routeResult.pageRouteType) {
          case PageRouteType.material:
            return MaterialPageRoute(settings: settings, builder: (c) => page);
          case PageRouteType.cupertino:
            return CupertinoPageRoute(settings: settings, builder: (c) => page);
          case PageRouteType.transparent:
            return Platform.isIOS
                ? TransparentCupertinoPageRoute(
                    settings: settings, builder: (c) => page)
                : TransparentMaterialPageRoute(
                    settings: settings, builder: (c) => page);
//            return FFTransparentPageRoute(
//                settings: settings,
//                pageBuilder: (BuildContext context, Animation<double> animation,
//                        Animation<double> secondaryAnimation) =>
//                    page);
          default:
            return Platform.isIOS
                ? CupertinoPageRoute(settings: settings, builder: (c) => page)
                : MaterialPageRoute(settings: settings, builder: (c) => page);
        }
      },
    ));
  }
}

String _imageTestUrl;
String get imageTestUrl =>
    _imageTestUrl ?? "https://photo.tuchong.com/4870004/f/298584322.jpg";

///save netwrok image to photo
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  var data = await getNetworkImageData(url, useCache: useCache);
  var filePath = await ImagePickerSaver.saveFile(fileData: data);
  return filePath != null && filePath != "";
}
