import 'package:example/common/widget/memory_usage_view.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://MemoryUsageDemo',
  routeName: 'MemoryUsage',
  description: 'show how to reduce memory usage.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 1,
  },
)
class MemoryUsageDemo extends StatefulWidget {
  @override
  _MemoryUsageDemoState createState() => _MemoryUsageDemoState();
}

class _MemoryUsageDemoState extends State<MemoryUsageDemo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MemoryUsage'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () {},
            ),
          ],
        ),
        body: MemoryUsageView());
  }
}
