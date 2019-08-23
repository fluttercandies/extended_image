import 'package:example/common/item_builder.dart';
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: "fluttercandies://imagelist",
    routeName: "image list",
    description: "show cache image in list")
class ImageListDemo extends StatefulWidget {
  @override
  _ImageListDemoState createState() => _ImageListDemoState();
}

class _ImageListDemoState extends State<ImageListDemo> {
  TuChongRepository listSourceRepository = TuChongRepository();
  @override
  void dispose() {
    listSourceRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("ImageListDemo"),
          ),
          Expanded(
            child: LoadingMoreList(
              ListConfig<TuChongItem>(
                  itemBuilder: ItemBuilder.itemBuilder,
                  sourceList: listSourceRepository,
                  padding: EdgeInsets.all(0.0)),
            ),
          )
        ],
      ),
    );
  }
}
