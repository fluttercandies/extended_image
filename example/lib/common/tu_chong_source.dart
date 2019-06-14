import 'dart:convert' show json;

import 'package:flutter/material.dart';

class TuChongSource {
  int counts;
  bool isHistory;
  bool more;
  String message;
  String result;
  List<TuChongItem> feedList;

  TuChongSource.fromParams(
      {this.counts,
      this.isHistory,
      this.more,
      this.message,
      this.result,
      this.feedList});

  factory TuChongSource(jsonStr) => jsonStr == null
      ? null
      : jsonStr is String
          ? new TuChongSource.fromJson(json.decode(jsonStr))
          : new TuChongSource.fromJson(jsonStr);

  TuChongSource.fromJson(jsonRes) {
    counts = jsonRes['counts'];
    isHistory = jsonRes['is_history'];
    more = jsonRes['more'];
    message = jsonRes['message'];
    result = jsonRes['result'];
    feedList = jsonRes['feedList'] == null ? null : [];

    for (var feedListItem in feedList == null ? [] : jsonRes['feedList']) {
      feedList.add(
          feedListItem == null ? null : new TuChongItem.fromJson(feedListItem));
    }
  }

  @override
  String toString() {
    return '{"counts": $counts,"is_history": $isHistory,"more": $more,"message": ${message != null ? '${json.encode(message)}' : 'null'},"result": ${result != null ? '${json.encode(result)}' : 'null'},"feedList": $feedList}';
  }
}

class TuChongItem {
  Object titleImage;
  int comments;
  int favorites;
  int imageCount;
  int postId;
  int shares;
  int views;
  bool collected;
  bool delete;
  bool isFavorite;
  bool recommend;
  bool rewardable;
  bool update;
  String authorId;
  String content;
  String createdAt;
  String dataType;
  String excerpt;
  String parentComments;
  String passedTime;
  String publishedAt;
  String recomType;
  String rewards;
  String rqtId;
  String siteId;
  String title;
  String type;
  String url;
  List<dynamic> commentListPrefix;
  List<String> eventTags;
  List<dynamic> favoriteListPrefix;
  List<ImageItem> images;
  List<dynamic> rewardListPrefix;
  List<dynamic> sites;
  List<String> tags;
  Site site;

  bool get hasImage {
    return images != null && images.length > 0;
  }

  Size get imageSize {
    if (!hasImage) return Size(0, 0);
    return Size(images[0].width.toDouble(), images[0].height.toDouble());
  }

  String get imageUrl {
    if (!hasImage) return "";
    return "https://photo.tuchong.com/" +
        images[0].userId.toString() +
        "/f/" +
        images[0].imgId.toString() +
        ".jpg";
  }

  TuChongItem.fromParams(
      {this.titleImage,
      this.comments,
      this.favorites,
      this.imageCount,
      this.postId,
      this.shares,
      this.views,
      this.collected,
      this.delete,
      this.isFavorite,
      this.recommend,
      this.rewardable,
      this.update,
      this.authorId,
      this.content,
      this.createdAt,
      this.dataType,
      this.excerpt,
      this.parentComments,
      this.passedTime,
      this.publishedAt,
      this.recomType,
      this.rewards,
      this.rqtId,
      this.siteId,
      this.title,
      this.type,
      this.url,
      this.commentListPrefix,
      this.eventTags,
      this.favoriteListPrefix,
      this.images,
      this.rewardListPrefix,
      this.sites,
      this.tags,
      this.site});

  TuChongItem.fromJson(jsonRes) {
    titleImage = jsonRes['title_image'];
    comments = jsonRes['comments'];
    favorites = jsonRes['favorites'];
    imageCount = jsonRes['image_count'];
    postId = jsonRes['post_id'];
    shares = jsonRes['shares'];
    views = jsonRes['views'];
    collected = jsonRes['collected'];
    delete = jsonRes['delete'];
    isFavorite = jsonRes['is_favorite'];
    recommend = jsonRes['recommend'];
    rewardable = jsonRes['rewardable'];
    update = jsonRes['update'];
    authorId = jsonRes['author_id'];
    content = jsonRes['content'];
    createdAt = jsonRes['created_at'];
    dataType = jsonRes['data_type'];
    excerpt = jsonRes['excerpt'];
    parentComments = jsonRes['parent_comments'];
    passedTime = jsonRes['passed_time'];
    publishedAt = jsonRes['published_at'];
    recomType = jsonRes['recom_type'];
    rewards = jsonRes['rewards'];
    rqtId = jsonRes['rqt_id'];
    siteId = jsonRes['site_id'];
    title = jsonRes['title'];
    type = jsonRes['type'];
    url = jsonRes['url'];
    commentListPrefix = jsonRes['comment_list_prefix'] == null ? null : [];

    for (var commentListPrefixItem
        in commentListPrefix == null ? [] : jsonRes['comment_list_prefix']) {
      commentListPrefix.add(commentListPrefixItem);
    }

    eventTags = jsonRes['event_tags'] == null ? null : [];

    for (var eventTagsItem in eventTags == null ? [] : jsonRes['event_tags']) {
      eventTags.add(eventTagsItem);
    }

    favoriteListPrefix = jsonRes['favorite_list_prefix'] == null ? null : [];

    for (var favoriteListPrefixItem
        in favoriteListPrefix == null ? [] : jsonRes['favorite_list_prefix']) {
      favoriteListPrefix.add(favoriteListPrefixItem);
    }

    images = jsonRes['images'] == null ? null : [];

    for (var imagesItem in images == null ? [] : jsonRes['images']) {
      images
          .add(imagesItem == null ? null : new ImageItem.fromJson(imagesItem));
    }

    rewardListPrefix = jsonRes['reward_list_prefix'] == null ? null : [];

    for (var rewardListPrefixItem
        in rewardListPrefix == null ? [] : jsonRes['reward_list_prefix']) {
      rewardListPrefix.add(rewardListPrefixItem);
    }

    sites = jsonRes['sites'] == null ? null : [];

    for (var sitesItem in sites == null ? [] : jsonRes['sites']) {
      sites.add(sitesItem);
    }

    tags = jsonRes['tags'] == null ? null : [];

    for (var tagsItem in tags == null ? [] : jsonRes['tags']) {
      tags.add(tagsItem);
    }

    site = jsonRes['site'] == null ? null : new Site.fromJson(jsonRes['site']);
  }

  @override
  String toString() {
    return '{"title_image": ${title != null ? '${json.encode(title)}' : 'null'}Image,"comments": $comments,"favorites": $favorites,"image_count": $imageCount,"post_id": $postId,"shares": $shares,"views": $views,"collected": $collected,"delete": $delete,"is_favorite": $isFavorite,"recommend": $recommend,"rewardable": $rewardable,"update": $update,"author_id": ${authorId != null ? '${json.encode(authorId)}' : 'null'},"content": ${content != null ? '${json.encode(content)}' : 'null'},"created_at": ${createdAt != null ? '${json.encode(createdAt)}' : 'null'},"data_type": ${dataType != null ? '${json.encode(dataType)}' : 'null'},"excerpt": ${excerpt != null ? '${json.encode(excerpt)}' : 'null'},"parent_comments": ${parentComments != null ? '${json.encode(parentComments)}' : 'null'},"passed_time": ${passedTime != null ? '${json.encode(passedTime)}' : 'null'},"published_at": ${publishedAt != null ? '${json.encode(publishedAt)}' : 'null'},"recom_type": ${recomType != null ? '${json.encode(recomType)}' : 'null'},"rewards": ${rewards != null ? '${json.encode(rewards)}' : 'null'},"rqt_id": ${rqtId != null ? '${json.encode(rqtId)}' : 'null'},"site_id": ${siteId != null ? '${json.encode(siteId)}' : 'null'},"title": ${title != null ? '${json.encode(title)}' : 'null'},"type": ${type != null ? '${json.encode(type)}' : 'null'},"url": ${url != null ? '${json.encode(url)}' : 'null'},"comment_list_prefix": $commentListPrefix,"event_tags": $eventTags,"favorite_list_prefix": $favoriteListPrefix,"images": $images,"reward_list_prefix": $rewardListPrefix,"sites": $sites,"tags": $tags,"site": $site}';
  }
}

class Site {
  int followers;
  int verifications;
  int verifiedType;
  bool hasEverphotoNote;
  bool isBindEverphoto;
  bool isFollowing;
  bool verified;
  String description;
  String domain;
  String icon;
  String name;
  String siteId;
  String type;
  String url;
  String verifiedReason;
  List<dynamic> verificationList;

  Site.fromParams(
      {this.followers,
      this.verifications,
      this.verifiedType,
      this.hasEverphotoNote,
      this.isBindEverphoto,
      this.isFollowing,
      this.verified,
      this.description,
      this.domain,
      this.icon,
      this.name,
      this.siteId,
      this.type,
      this.url,
      this.verifiedReason,
      this.verificationList});

  Site.fromJson(jsonRes) {
    followers = jsonRes['followers'];
    verifications = jsonRes['verifications'];
    verifiedType = jsonRes['verified_type'];
    hasEverphotoNote = jsonRes['has_everphoto_note'];
    isBindEverphoto = jsonRes['is_bind_everphoto'];
    isFollowing = jsonRes['is_following'];
    verified = jsonRes['verified'];
    description = jsonRes['description'];
    domain = jsonRes['domain'];
    icon = jsonRes['icon'];
    name = jsonRes['name'];
    var id = jsonRes['site_id'];
    if (id is int) {
      siteId = id.toString();
    } else if (id is String) {
      siteId = id;
    }

    type = jsonRes['type'];
    url = jsonRes['url'];
    verifiedReason = jsonRes['verified_reason'];
    verificationList = jsonRes['verification_list'] == null ? null : [];

    for (var verificationListItem
        in verificationList == null ? [] : jsonRes['verification_list']) {
      verificationList.add(verificationListItem);
    }
  }

  @override
  String toString() {
    return '{"followers": $followers,"verifications": $verifications,"verified_type": $verifiedType,"has_everphoto_note": $hasEverphotoNote,"is_bind_everphoto": $isBindEverphoto,"is_following": $isFollowing,"verified": $verified,"description": ${description != null ? '${json.encode(description)}' : 'null'},"domain": ${domain != null ? '${json.encode(domain)}' : 'null'},"icon": ${icon != null ? '${json.encode(icon)}' : 'null'},"name": ${name != null ? '${json.encode(name)}' : 'null'},"site_id": ${siteId != null ? '${json.encode(siteId)}' : 'null'},"type": ${type != null ? '${json.encode(type)}' : 'null'},"url": ${url != null ? '${json.encode(url)}' : 'null'},"verified_reason": ${verifiedReason != null ? '${json.encode(verifiedReason)}' : 'null'},"verification_list": $verificationList}';
  }
}

class ImageItem {
  int height;
  int imgId;
  int userId;
  int width;
  String description;
  String excerpt;
  String title;

  ImageItem.fromParams(
      {this.height,
      this.imgId,
      this.userId,
      this.width,
      this.description,
      this.excerpt,
      this.title});

  ImageItem.fromJson(jsonRes) {
    height = jsonRes['height'];
    imgId = jsonRes['img_id'];
    userId = jsonRes['user_id'];
    width = jsonRes['width'];
    description = jsonRes['description'];
    excerpt = jsonRes['excerpt'];
    title = jsonRes['title'];
  }

  @override
  String toString() {
    return '{"height": $height,"img_id": $imgId,"user_id": $userId,"width": $width,"description": ${description != null ? '${json.encode(description)}' : 'null'},"excerpt": ${excerpt != null ? '${json.encode(excerpt)}' : 'null'},"title": ${title != null ? '${json.encode(title)}' : 'null'}}';
  }
}
