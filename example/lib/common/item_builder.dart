import 'dart:async';

import 'package:example/common/tu_chong_source.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class ItemBuilder {
  static Widget itemBuilder(BuildContext context, TuChongItem item, int index) {
    return Container(
      height: 200.0,
      child: Stack(
        children: <Widget>[
          Positioned(
            child: ExtendedImage.network(
              item.imageUrl,
              fit: BoxFit.fill,
              width: double.infinity,
              //height: 200.0,
              height: double.infinity,
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              height: 40.0,
              color: Colors.grey.withOpacity(0.5),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.comment,
                        color: Colors.amberAccent,
                      ),
                      Text(
                        item.comments.toString(),
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  LikeButton(
                    size: 20.0,
                    isLiked: item.is_favorite,
                    likeCount: item.favorites,
                    countBuilder: (int count, bool isLiked, String text) {
                      var color = isLiked ? Colors.pinkAccent : Colors.grey;
                      Widget result;
                      if (count == 0) {
                        result = Text(
                          "love",
                          style: TextStyle(color: color),
                        );
                      } else
                        result = Text(
                          count >= 1000
                              ? (count / 1000.0).toStringAsFixed(1) + "k"
                              : text,
                          style: TextStyle(color: color),
                        );
                      return result;
                    },
                    likeCountAnimationType: item.favorites < 1000
                        ? LikeCountAnimationType.part
                        : LikeCountAnimationType.none,
                    onTap: (bool isLiked) {
                      return onLikeButtonTap(isLiked, item);
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  static Future<bool> onLikeButtonTap(bool isLiked, TuChongItem item) {
    ///send your request here
    ///
    final Completer<bool> completer = new Completer<bool>();
    Timer(const Duration(milliseconds: 200), () {
      item.is_favorite = !item.is_favorite;
      item.favorites =
          item.is_favorite ? item.favorites + 1 : item.favorites - 1;

      // if your request is failed,return null,
      completer.complete(item.is_favorite);
    });
    return completer.future;
  }
}
