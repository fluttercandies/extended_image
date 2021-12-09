import 'package:extended_image/extended_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'common/widget/memory_usage_view.dart';
import 'example_route.dart';
import 'example_routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    if (!kIsWeb) {
      clearDiskCachedImages(duration: const Duration(days: 7));
    }
  }

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
      builder: (BuildContext c, Widget? w) {
        w = Stack(
          children: <Widget>[
            Positioned.fill(child: w!),
            if (kDebugMode) MemoryUsageView(),
          ],
        );
        if (!kIsWeb) {
          final MediaQueryData data = MediaQuery.of(c);
          w = MediaQuery(
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
  final Widget? child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title!,
        ),
      ),
      body: child,
    );
  }
}

String get imageTestUrl => 'https://photo.tuchong.com/4870004/f/298584322.jpg';
