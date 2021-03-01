import 'package:example/common/data/tu_chong_repository.dart';
import 'package:example/common/utils/screen_util.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'example_route.dart';
import 'example_routes.dart';

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
      initialRoute: Routes.fluttercandiesMainpage,
      onGenerateRoute: (RouteSettings settings) {
        return onGenerateRoute(
          settings: settings,
          getRouteSettings: getRouteSettings,
          // routeSettingsWrapper: (FFRouteSettings ffRouteSettings) {
          //   if (ffRouteSettings.name == Routes.fluttercandiesMainpage ||
          //       ffRouteSettings.name == Routes.fluttercandiesDemogrouppage) {
          //     return ffRouteSettings;
          //   }
          //   return ffRouteSettings.copyWith(
          //       widget: CommonWidget(
          //     child: ffRouteSettings.widget,
          //     title: ffRouteSettings.routeName,
          //   ));
          // },
        );
      },
    ));
  }
}

class CommonWidget extends StatelessWidget {
  const CommonWidget({
    this.child,
    this.title,
  });
  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
      ),
      body: child,
    );
  }
}

String _imageTestUrl;
String get imageTestUrl =>
    _imageTestUrl ?? 'https://photo.tuchong.com/4870004/f/298584322.jpg';
