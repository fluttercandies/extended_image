import 'package:example/common/item_builder.dart';
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

class ImageListDemo extends StatefulWidget {
  @override
  _ImageListDemoState createState() => _ImageListDemoState();
}

class _ImageListDemoState extends State<ImageListDemo> {
  TuChongRepository listSourceRepository;
  @override
  void initState() {
    // TODO: implement initState
    listSourceRepository = new TuChongRepository();
    super.initState();
  }

  @override
  void dispose() {
    listSourceRepository?.dispose();
    // TODO: implement dispose
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
//                    showGlowLeading: false,
//                    showGlowTrailing: false,
                  padding: EdgeInsets.all(0.0)),
            ),
          )
        ],
      ),
    );
  }
}
