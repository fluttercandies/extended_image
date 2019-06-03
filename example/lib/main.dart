import 'package:example/common/tu_chong_repository.dart';
import 'package:example/custom_image_demo.dart';
import 'package:example/crop_image_demo.dart';
import 'package:example/image_demo.dart';
import 'package:example/image_list_demo.dart';
import 'package:example/paint_image_demo.dart';
import 'package:example/photo_view_demo.dart';
import 'package:example/zoom_image_demo.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import "package:oktoast/oktoast.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Page> pages = new List<Page>();
  TuChongRepository listSourceRepository;
  @override
  void initState() {
    // TODO: implement initState
    pages.add(Page(
        PageType.Image,
        "cache image"
        "save to photo Library"
        "image border,shape,borderRadius"));
    pages.add(Page(PageType.List, "show cache image in list"));
    pages
        .add(Page(PageType.Custom, "show image with loading,failed,animation"));
    pages.add(Page(PageType.Crop, "show how to crop image"));
    pages.add(Page(PageType.Paint, "show how to paint any thing before image"));
    pages.add(Page(PageType.Zoom, "show how to zoom/pan image"));
    pages.add(Page(PageType.PhotoView,
        "show how to zoom/pan image in page view like WeChat"));

    ///clear cache image from 7 days before
    clearDiskCachedImages(duration: Duration(days: 7));
    listSourceRepository = new TuChongRepository();
    listSourceRepository.loadData().then((result) {
      if (listSourceRepository.length > 0)
        _imageTestUrl = listSourceRepository.first.imageUrl;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var content = ListView.builder(
      itemBuilder: (_, int index) {
        var page = pages[index];

        Widget pageWidget;
        return Container(
          margin: EdgeInsets.all(20.0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  (index + 1).toString() +
                      "." +
                      page.type.toString().replaceAll("PageType.", ""),
                  //style: TextStyle(inherit: false),
                ),
                Text(
                  page.description,
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            onTap: () {
              switch (page.type) {
                case PageType.Image:
                  pageWidget = new ImageDemo();
                  break;
                case PageType.List:
                  pageWidget = ImageListDemo();
                  break;
                case PageType.Custom:
                  pageWidget = CustomImageDemo();
                  break;
                case PageType.Crop:
                  pageWidget = CropImageDemo();
                  break;
                case PageType.Paint:
                  pageWidget = PaintImageDemo();
                  break;
                case PageType.Zoom:
                  pageWidget = ZoomImageDemo();
                  break;
                case PageType.PhotoView:
                  pageWidget = PhotoViewDemo();
                  break;
                default:
                  break;
              }
              Navigator.push(context,
                  new MaterialPageRoute(builder: (BuildContext context) {
                return pageWidget;
              }));
            },
          ),
        );
      },
      itemCount: pages.length,
    );

    return MaterialApp(
      builder: (c, w) {
        ScreenUtil.instance =
            ScreenUtil(width: 750, height: 1334, allowFontScaling: true)
              ..init(c);
        var data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: Scaffold(
            body: w,
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
          ),
        );
      },
      home: content,
    );
  }
}

class Page {
  final PageType type;
  final String description;
  Page(this.type, this.description);
}

enum PageType { Image, List, Custom, Crop, Paint, Zoom, PhotoView }

String _imageTestUrl;
String get imageTestUrl =>
    _imageTestUrl ?? "https://photo.tuchong.com/4870004/f/298584322.jpg";

///save netwrok image to photo
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  var data = await getNetworkImageData(url, useCache: useCache);
  var filePath = await ImagePickerSaver.saveFile(fileData: data);
  return filePath != null && filePath != "";
}
