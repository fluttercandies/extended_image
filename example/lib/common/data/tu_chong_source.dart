import 'dart:convert' show json;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class ImageItem {
  String get imageUrl {
    return "https://photo.tuchong.com/$userId/f/$imgId.jpg";
  }

  final String description;
  final String excerpt;
  final int height;
  final int imgId;
  final String imgIdStr;
  final String title;
  final int userId;
  final int width;

  ImageItem({
    this.description,
    this.excerpt,
    this.height,
    this.imgId,
    this.imgIdStr,
    this.title,
    this.userId,
    this.width,
  });

  factory ImageItem.fromJson(jsonRes) => jsonRes == null
      ? null
      : ImageItem(
          description: jsonRes['description'],
          excerpt: jsonRes['excerpt'],
          height: jsonRes['height'],
          imgId: jsonRes['img_id'],
          imgIdStr: jsonRes['img_id_str'],
          title: jsonRes['title'],
          userId: jsonRes['user_id'],
          width: jsonRes['width'],
        );

  Map<String, dynamic> toJson() => {
        'description': description,
        'excerpt': excerpt,
        'height': height,
        'img_id': imgId,
        'img_id_str': imgIdStr,
        'title': title,
        'user_id': userId,
        'width': width,
      };

  @override
  String toString() {
    return json.encode(this);
  }

  ImageProvider createNetworkImage() {
    return ExtendedNetworkImageProvider(imageUrl);
  }

  ImageProvider createResizeImage() {
    return ResizeImage(ExtendedNetworkImageProvider(imageUrl),
        width: width ~/ 5, height: height ~/ 5);
  }

  void clearCache() {
    createNetworkImage().evict();
    createResizeImage().evict();
  }
}

class TuChongSource {
  final int counts;
  final List<TuChongItem> feedList;
  final bool isHistory;
  final String message;
  final bool more;
  final String result;

  TuChongSource({
    this.counts,
    this.feedList,
    this.isHistory,
    this.message,
    this.more,
    this.result,
  });

  factory TuChongSource.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<TuChongItem> feedList = jsonRes['feedList'] is List ? [] : null;
    if (feedList != null) {
      for (var item in jsonRes['feedList']) {
        if (item != null) {
          feedList.add(TuChongItem.fromJson(item));
        }
      }
    }

    return TuChongSource(
      counts: jsonRes['counts'],
      feedList: feedList,
      isHistory: jsonRes['is_history'],
      message: jsonRes['message'],
      more: jsonRes['more'],
      result: jsonRes['result'],
    );
  }
  Map<String, dynamic> toJson() => {
        'counts': counts,
        'feedList': feedList,
        'is_history': isHistory,
        'message': message,
        'more': more,
        'result': result,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class TuChongItem {
  final String authorId;
  final bool collected;
  final List<Object> commentListPrefix;
  final int comments;
  final String content;
  final String createdAt;
  final String dataType;
  final bool delete;
  final List<String> eventTags;
  final String excerpt;
  final List<Object> favoriteListPrefix;
  int favorites;
  final int imageCount;
  final List<ImageItem> images;
  bool isFavorite;
  final bool lastRead;
  final String parentComments;
  final String passedTime;
  final int postId;
  final String publishedAt;
  final bool recommend;
  final String recomType;
  final bool rewardable;
  final List<Object> rewardListPrefix;
  final String rewards;
  final String rqtId;
  final int shares;
  final Site site;
  final String siteId;
  final List<Object> sites;
  final List<String> tags;
  final String title;
  final Object titleImage;
  final String type;
  final bool update;
  final String url;
  final int views;
  final List<Color> tagColors = List<Color>();

  TuChongItem({
    this.authorId,
    this.collected,
    this.commentListPrefix,
    this.comments,
    this.content,
    this.createdAt,
    this.dataType,
    this.delete,
    this.eventTags,
    this.excerpt,
    this.favoriteListPrefix,
    this.favorites,
    this.imageCount,
    this.images,
    this.isFavorite,
    this.lastRead,
    this.parentComments,
    this.passedTime,
    this.postId,
    this.publishedAt,
    this.recommend,
    this.recomType,
    this.rewardable,
    this.rewardListPrefix,
    this.rewards,
    this.rqtId,
    this.shares,
    this.site,
    this.siteId,
    this.sites,
    this.tags,
    this.title,
    this.titleImage,
    this.type,
    this.update,
    this.url,
    this.views,
  });

  bool get hasImage {
    return images != null && images.length > 0;
  }

  Size imageRawSize;

  Size get imageSize {
    if (!hasImage) return Size(0, 0);
    return Size(images[0].width.toDouble(), images[0].height.toDouble());
  }

  String get imageUrl {
    if (!hasImage) return "";
    return "https://photo.tuchong.com/${images[0].userId}/f/${images[0].imgId}.jpg";
  }

  String get avatarUrl => site.icon;

  String get imageTitle {
    if (!hasImage) return title;

    return images[0].title;
  }

  String get imageDescription {
    if (!hasImage) return content;

    return images[0].description;
  }

  factory TuChongItem.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<Object> commentListPrefix =
        jsonRes['comment_list_prefix'] is List ? [] : null;
    if (commentListPrefix != null) {
      for (var item in jsonRes['comment_list_prefix']) {
        if (item != null) {
          commentListPrefix.add(item);
        }
      }
    }

    List<String> eventTags = jsonRes['event_tags'] is List ? [] : null;
    if (eventTags != null) {
      for (var item in jsonRes['event_tags']) {
        if (item != null) {
          eventTags.add(item);
        }
      }
    }

    List<Object> favoriteListPrefix =
        jsonRes['favorite_list_prefix'] is List ? [] : null;
    if (favoriteListPrefix != null) {
      for (var item in jsonRes['favorite_list_prefix']) {
        if (item != null) {
          favoriteListPrefix.add(item);
        }
      }
    }

    List<ImageItem> images = jsonRes['images'] is List ? [] : null;
    if (images != null) {
      for (var item in jsonRes['images']) {
        if (item != null) {
          images.add(ImageItem.fromJson(item));
        }
      }
    }

    List<Object> rewardListPrefix =
        jsonRes['reward_list_prefix'] is List ? [] : null;
    if (rewardListPrefix != null) {
      for (var item in jsonRes['reward_list_prefix']) {
        if (item != null) {
          rewardListPrefix.add(item);
        }
      }
    }

    List<Object> sites = jsonRes['sites'] is List ? [] : null;
    if (sites != null) {
      for (var item in jsonRes['sites']) {
        if (item != null) {
          sites.add(item);
        }
      }
    }
    final tagColors = List<Color>();
    List<String> tags = jsonRes['tags'] is List ? [] : null;
    if (tags != null) {
      final int maxNum = 6;
      for (var tagsItem in tags == null ? [] : jsonRes['tags']) {
        tags.add(tagsItem);
        tagColors.add(Color.fromARGB(255, Random.secure().nextInt(255),
            Random.secure().nextInt(255), Random.secure().nextInt(255)));
        if (tags.length == maxNum) break;
      }
    }

    return TuChongItem(
      authorId: jsonRes['author_id'],
      collected: jsonRes['collected'],
      commentListPrefix: commentListPrefix,
      comments: jsonRes['comments'],
      content: jsonRes['content'],
      createdAt: jsonRes['created_at'],
      dataType: jsonRes['data_type'],
      delete: jsonRes['delete'],
      eventTags: eventTags,
      excerpt: jsonRes['excerpt'],
      favoriteListPrefix: favoriteListPrefix,
      favorites: jsonRes['favorites'],
      imageCount: jsonRes['image_count'],
      images: images,
      isFavorite: jsonRes['is_favorite'],
      lastRead: jsonRes['last_read'],
      parentComments: jsonRes['parent_comments'],
      passedTime: jsonRes['passed_time'],
      postId: jsonRes['post_id'],
      publishedAt: jsonRes['published_at'],
      recommend: jsonRes['recommend'],
      recomType: jsonRes['recom_type'],
      rewardable: jsonRes['rewardable'],
      rewardListPrefix: rewardListPrefix,
      rewards: jsonRes['rewards'],
      rqtId: jsonRes['rqt_id'],
      shares: jsonRes['shares'],
      site: Site.fromJson(jsonRes['site']),
      siteId: jsonRes['site_id'],
      sites: sites,
      tags: tags,
      title: jsonRes['title'],
      titleImage: jsonRes['title_image'],
      type: jsonRes['type'],
      update: jsonRes['update'],
      url: jsonRes['url'],
      views: jsonRes['views'],
    )..tagColors.addAll(tagColors);
  }
  Map<String, dynamic> toJson() => {
        'author_id': authorId,
        'collected': collected,
        'comment_list_prefix': commentListPrefix,
        'comments': comments,
        'content': content,
        'created_at': createdAt,
        'data_type': dataType,
        'delete': delete,
        'event_tags': eventTags,
        'excerpt': excerpt,
        'favorite_list_prefix': favoriteListPrefix,
        'favorites': favorites,
        'image_count': imageCount,
        'images': images,
        'is_favorite': isFavorite,
        'last_read': lastRead,
        'parent_comments': parentComments,
        'passed_time': passedTime,
        'post_id': postId,
        'published_at': publishedAt,
        'recommend': recommend,
        'recom_type': recomType,
        'rewardable': rewardable,
        'reward_list_prefix': rewardListPrefix,
        'rewards': rewards,
        'rqt_id': rqtId,
        'shares': shares,
        'site': site,
        'site_id': siteId,
        'sites': sites,
        'tags': tags,
        'title': title,
        'title_image': titleImage,
        'type': type,
        'update': update,
        'url': url,
        'views': views,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Site {
  final String description;
  final String domain;
  final int followers;
  final bool hasEverphotoNote;
  final String icon;
  final bool isBindEverphoto;
  final bool isFollowing;
  final String name;
  final String siteId;
  final String type;
  final String url;
  final List<VerificationList> verificationList;
  final int verifications;
  final bool verified;

  Site({
    this.description,
    this.domain,
    this.followers,
    this.hasEverphotoNote,
    this.icon,
    this.isBindEverphoto,
    this.isFollowing,
    this.name,
    this.siteId,
    this.type,
    this.url,
    this.verificationList,
    this.verifications,
    this.verified,
  });

  factory Site.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<VerificationList> verificationList =
        jsonRes['verification_list'] is List ? [] : null;
    if (verificationList != null) {
      for (var item in jsonRes['verification_list']) {
        if (item != null) {
          verificationList.add(VerificationList.fromJson(item));
        }
      }
    }

    return Site(
      description: jsonRes['description'],
      domain: jsonRes['domain'],
      followers: jsonRes['followers'],
      hasEverphotoNote: jsonRes['has_everphoto_note'],
      icon: jsonRes['icon'],
      isBindEverphoto: jsonRes['is_bind_everphoto'],
      isFollowing: jsonRes['is_following'],
      name: jsonRes['name'],
      siteId: jsonRes['site_id'],
      type: jsonRes['type'],
      url: jsonRes['url'],
      verificationList: verificationList,
      verifications: jsonRes['verifications'],
      verified: jsonRes['verified'],
    );
  }
  Map<String, dynamic> toJson() => {
        'description': description,
        'domain': domain,
        'followers': followers,
        'has_everphoto_note': hasEverphotoNote,
        'icon': icon,
        'is_bind_everphoto': isBindEverphoto,
        'is_following': isFollowing,
        'name': name,
        'site_id': siteId,
        'type': type,
        'url': url,
        'verification_list': verificationList,
        'verifications': verifications,
        'verified': verified,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class VerificationList {
  final String verificationReason;
  final int verificationType;

  VerificationList({
    this.verificationReason,
    this.verificationType,
  });

  factory VerificationList.fromJson(jsonRes) => jsonRes == null
      ? null
      : VerificationList(
          verificationReason: jsonRes['verification_reason'],
          verificationType: jsonRes['verification_type'],
        );
  Map<String, dynamic> toJson() => {
        'verification_reason': verificationReason,
        'verification_type': verificationType,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
