import 'package:http_client_helper/http_client_helper.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:example/common/tu_chong_source.dart';
import 'dart:async';
import 'dart:convert';

class TuChongRepository extends LoadingMoreBase<TuChongItem> {
  int pageindex = 1;

  @override
  // TODO: implement hasMore
  bool _hasMore = true;
  bool forceRefresh = false;
  bool get hasMore => (_hasMore && length < 100) || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    // TODO: implement onRefresh
    _hasMore = true;
    pageindex = 1;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    // TODO: implement getData
    String url = "";
    if (this.length == 0) {
      url = "https://api.tuchong.com/feed-app";
    } else {
      int lastPostId = this[this.length - 1].post_id;
      url =
          "https://api.tuchong.com/feed-app?post_id=${lastPostId}&page=${pageindex}&type=loadmore";
    }
    bool isSuccess = false;
    try {
      //to show loading more clearly, in your app,remove this
      //await Future.delayed(Duration(milliseconds: 500, seconds: 1));

      var result = await HttpClientHelper.get(url);

      var source = TuChongSource.fromJson(json.decode(result.body));
      if (pageindex == 1) {
        this.clear();
      }

      source.feedList.forEach((item) {
        if (item.hasImage && !this.contains(item) && hasMore) {
          this.add(item);
        }
      });

      _hasMore = source.feedList.length != 0;
      pageindex++;
//      this.clear();
//      _hasMore=false;
      isSuccess = true;
    } catch (exception) {
      isSuccess = false;
      print(exception);
    }
    return isSuccess;
  }
}
