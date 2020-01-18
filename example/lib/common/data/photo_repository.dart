import 'dart:convert';

import 'package:http_client_helper/http_client_helper.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'picsum_photo.dart';

class PicsumPhotoRepository extends LoadingMoreBase<Photo> {
  int page = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  @override
  bool get hasMore => (_hasMore && length < 300) || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    page = 1;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    final url = 'https://picsum.photos/v2/list?page=$page&limit=20';

    bool isSuccess = false;
    try {
      //to show loading more clearly, in your app,remove this
      await Future.delayed(Duration(milliseconds: 500));

      final result = await HttpClientHelper.get(url);

      final source = PicsumPhoto.fromJson({'data': json.decode(result.body)});
      if (page == 1) {
        this.clear();
      }
      for (var item in source.data) {
        if (!this.contains(item) && hasMore) this.add(item);
      }

      _hasMore = source.data.length != 0;
      page++;
//      this.clear();
//      _hasMore=false;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      print(exception);
      print(stack);
    }
    return isSuccess;
  }
}
