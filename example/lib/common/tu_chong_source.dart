import 'dart:convert' show json;

class TuChongSource {
  int counts;
  bool is_history;
  bool more;
  String message;
  String result;
  List<TuChongItem> feedList;

  TuChongSource.fromParams(
      {this.counts,
      this.is_history,
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
    is_history = jsonRes['is_history'];
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
    return '{"counts": $counts,"is_history": $is_history,"more": $more,"message": ${message != null ? '${json.encode(message)}' : 'null'},"result": ${result != null ? '${json.encode(result)}' : 'null'},"feedList": $feedList}';
  }
}

class TuChongItem {
  Object title_image;
  int comments;
  int favorites;
  int image_count;
  int post_id;
  int views;
  bool collected;
  bool delete;
  bool is_favorite;
  bool rewardable;
  bool update;
  String author_id;
  String content;
  String created_at;
  String data_type;
  String excerpt;
  String parent_comments;
  String passed_time;
  String published_at;
  String recom_type;
  String rewards;
  String rqt_id;
  String site_id;
  String title;
  String type;
  String url;
  List<dynamic> comment_list_prefix;
  List<String> event_tags;
  List<dynamic> favorite_list_prefix;
  List<ImageItem> images;
  List<dynamic> reward_list_prefix;
  List<dynamic> sites;
  List<String> tags;
  Site site;

  bool get hasImage {
    return images != null && images.length > 0;
  }

  String get imageUrl {
    return "https://photo.tuchong.com/" +
        images[0].user_id.toString() +
        "/f/" +
        images[0].img_id.toString() +
        ".jpg";
  }

  TuChongItem.fromParams(
      {this.title_image,
      this.comments,
      this.favorites,
      this.image_count,
      this.post_id,
      this.views,
      this.collected,
      this.delete,
      this.is_favorite,
      this.rewardable,
      this.update,
      this.author_id,
      this.content,
      this.created_at,
      this.data_type,
      this.excerpt,
      this.parent_comments,
      this.passed_time,
      this.published_at,
      this.recom_type,
      this.rewards,
      this.rqt_id,
      this.site_id,
      this.title,
      this.type,
      this.url,
      this.comment_list_prefix,
      this.event_tags,
      this.favorite_list_prefix,
      this.images,
      this.reward_list_prefix,
      this.sites,
      this.tags,
      this.site});

  TuChongItem.fromJson(jsonRes) {
    title_image = jsonRes['title_image'];
    comments = jsonRes['comments'];
    favorites = jsonRes['favorites'];
    image_count = jsonRes['image_count'];
    post_id = jsonRes['post_id'];
    views = jsonRes['views'];
    collected = jsonRes['collected'];
    delete = jsonRes['delete'];
    is_favorite = jsonRes['is_favorite'];
    rewardable = jsonRes['rewardable'];
    update = jsonRes['update'];
    author_id = jsonRes['author_id'];
    content = jsonRes['content'];
    created_at = jsonRes['created_at'];
    data_type = jsonRes['data_type'];
    excerpt = jsonRes['excerpt'];
    parent_comments = jsonRes['parent_comments'];
    passed_time = jsonRes['passed_time'];
    published_at = jsonRes['published_at'];
    recom_type = jsonRes['recom_type'];
    rewards = jsonRes['rewards'];
    rqt_id = jsonRes['rqt_id'];
    site_id = jsonRes['site_id'];
    title = jsonRes['title'];
    type = jsonRes['type'];
    url = jsonRes['url'];
    comment_list_prefix = jsonRes['comment_list_prefix'] == null ? null : [];

    for (var comment_list_prefixItem
        in comment_list_prefix == null ? [] : jsonRes['comment_list_prefix']) {
      comment_list_prefix.add(comment_list_prefixItem);
    }

    event_tags = jsonRes['event_tags'] == null ? null : [];

    for (var event_tagsItem
        in event_tags == null ? [] : jsonRes['event_tags']) {
      event_tags.add(event_tagsItem);
    }

    favorite_list_prefix = jsonRes['favorite_list_prefix'] == null ? null : [];

    for (var favorite_list_prefixItem in favorite_list_prefix == null
        ? []
        : jsonRes['favorite_list_prefix']) {
      favorite_list_prefix.add(favorite_list_prefixItem);
    }

    images = jsonRes['images'] == null ? null : [];

    for (var imagesItem in images == null ? [] : jsonRes['images']) {
      images
          .add(imagesItem == null ? null : new ImageItem.fromJson(imagesItem));
    }

    reward_list_prefix = jsonRes['reward_list_prefix'] == null ? null : [];

    for (var reward_list_prefixItem
        in reward_list_prefix == null ? [] : jsonRes['reward_list_prefix']) {
      reward_list_prefix.add(reward_list_prefixItem);
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
    return '{"title_image": ${title != null ? '${json.encode(title)}' : 'null'}_image,"comments": $comments,"favorites": $favorites,"image_count": $image_count,"post_id": $post_id,"views": $views,"collected": $collected,"delete": $delete,"is_favorite": $is_favorite,"rewardable": $rewardable,"update": $update,"author_id": ${author_id != null ? '${json.encode(author_id)}' : 'null'},"content": ${content != null ? '${json.encode(content)}' : 'null'},"created_at": ${created_at != null ? '${json.encode(created_at)}' : 'null'},"data_type": ${data_type != null ? '${json.encode(data_type)}' : 'null'},"excerpt": ${excerpt != null ? '${json.encode(excerpt)}' : 'null'},"parent_comments": ${parent_comments != null ? '${json.encode(parent_comments)}' : 'null'},"passed_time": ${passed_time != null ? '${json.encode(passed_time)}' : 'null'},"published_at": ${published_at != null ? '${json.encode(published_at)}' : 'null'},"recom_type": ${recom_type != null ? '${json.encode(recom_type)}' : 'null'},"rewards": ${rewards != null ? '${json.encode(rewards)}' : 'null'},"rqt_id": ${rqt_id != null ? '${json.encode(rqt_id)}' : 'null'},"site_id": ${site_id != null ? '${json.encode(site_id)}' : 'null'},"title": ${title != null ? '${json.encode(title)}' : 'null'},"type": ${type != null ? '${json.encode(type)}' : 'null'},"url": ${url != null ? '${json.encode(url)}' : 'null'},"comment_list_prefix": $comment_list_prefix,"event_tags": $event_tags,"favorite_list_prefix": $favorite_list_prefix,"images": $images,"reward_list_prefix": $reward_list_prefix,"sites": $sites,"tags": $tags,"site": $site}';
  }

  @override
  bool operator ==(other) {
    // TODO: implement ==
    return other.post_id == post_id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => post_id;
}

class Site {
  int followers;
  int verifications;
  int verified_type;
  bool is_following;
  bool verified;
  String description;
  String domain;
  String icon;
  String name;
  String site_id;
  String type;
  String url;
  String verified_reason;
  List<VerificationItem> verification_list;

  Site.fromParams(
      {this.followers,
      this.verifications,
      this.verified_type,
      this.is_following,
      this.verified,
      this.description,
      this.domain,
      this.icon,
      this.name,
      this.site_id,
      this.type,
      this.url,
      this.verified_reason,
      this.verification_list});

  Site.fromJson(jsonRes) {
    followers = jsonRes['followers'];
    verifications = jsonRes['verifications'];
    verified_type = jsonRes['verified_type'];
    is_following = jsonRes['is_following'];
    verified = jsonRes['verified'];
    description = jsonRes['description'];
    domain = jsonRes['domain'];
    icon = jsonRes['icon'];
    name = jsonRes['name'];
    site_id = jsonRes['site_id'];
    type = jsonRes['type'];
    url = jsonRes['url'];
    verified_reason = jsonRes['verified_reason'];
    verification_list = jsonRes['verification_list'] == null ? null : [];

    for (var verification_listItem
        in verification_list == null ? [] : jsonRes['verification_list']) {
      verification_list.add(verification_listItem == null
          ? null
          : new VerificationItem.fromJson(verification_listItem));
    }
  }

  @override
  String toString() {
    return '{"followers": $followers,"verifications": $verifications,"verified_type": $verified_type,"is_following": $is_following,"verified": $verified,"description": ${description != null ? '${json.encode(description)}' : 'null'},"domain": ${domain != null ? '${json.encode(domain)}' : 'null'},"icon": ${icon != null ? '${json.encode(icon)}' : 'null'},"name": ${name != null ? '${json.encode(name)}' : 'null'},"site_id": ${site_id != null ? '${json.encode(site_id)}' : 'null'},"type": ${type != null ? '${json.encode(type)}' : 'null'},"url": ${url != null ? '${json.encode(url)}' : 'null'},"verified_reason": ${verified_reason != null ? '${json.encode(verified_reason)}' : 'null'},"verification_list": $verification_list}';
  }
}

class VerificationItem {
  int verification_type;
  String verification_reason;

  VerificationItem.fromParams(
      {this.verification_type, this.verification_reason});

  VerificationItem.fromJson(jsonRes) {
    verification_type = jsonRes['verification_type'];
    verification_reason = jsonRes['verification_reason'];
  }

  @override
  String toString() {
    return '{"verification_type": $verification_type,"verification_reason": ${verification_reason != null ? '${json.encode(verification_reason)}' : 'null'}}';
  }
}

class ImageItem {
  int height;
  int img_id;
  int user_id;
  int width;
  String description;
  String excerpt;
  String title;

  ImageItem.fromParams(
      {this.height,
      this.img_id,
      this.user_id,
      this.width,
      this.description,
      this.excerpt,
      this.title});

  ImageItem.fromJson(jsonRes) {
    height = jsonRes['height'];
    img_id = jsonRes['img_id'];
    user_id = jsonRes['user_id'];
    width = jsonRes['width'];
    description = jsonRes['description'];
    excerpt = jsonRes['excerpt'];
    title = jsonRes['title'];
  }

  @override
  String toString() {
    return '{"height": $height,"img_id": $img_id,"user_id": $user_id,"width": $width,"description": ${description != null ? '${json.encode(description)}' : 'null'},"excerpt": ${excerpt != null ? '${json.encode(excerpt)}' : 'null'},"title": ${title != null ? '${json.encode(title)}' : 'null'}}';
  }
}


