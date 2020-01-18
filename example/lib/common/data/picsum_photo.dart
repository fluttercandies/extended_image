///
///  create by zmtzawqlp on 2020/01/18
///

import 'dart:convert' show json;

import 'dart:ui';

class PicsumPhoto {
  final List<Photo> data;

  PicsumPhoto({
    this.data,
  });

  factory PicsumPhoto.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<Photo> list = jsonRes['data'] is List ? [] : null;
    if (list != null) {
      for (var item in jsonRes['data']) {
        if (item != null) {
          list.add(Photo.fromJson(item));
        }
      }
    }

    return PicsumPhoto(
      data: list,
    );
  }
  Map<String, dynamic> toJson() => {
        'list': data,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Photo {
  final String author;
  final String downloadUrl;
  final int height;
  final String id;
  final String url;
  final int width;

  Photo({
    this.author,
    this.downloadUrl,
    this.height,
    this.id,
    this.url,
    this.width,
  });

  factory Photo.fromJson(jsonRes) => jsonRes == null
      ? null
      : Photo(
          author: jsonRes['author'],
          downloadUrl: jsonRes['download_url'],
          height: jsonRes['height'],
          id: jsonRes['id'],
          url: jsonRes['url'],
          width: jsonRes['width'],
        );
  Map<String, dynamic> toJson() => {
        'author': author,
        'download_url': downloadUrl,
        'height': height,
        'id': id,
        'url': url,
        'width': width,
      };

  @override
  String toString() {
    return json.encode(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final Photo typedOther = other;
    bool result = id == typedOther.id && url == typedOther.url;
    return result;
  }

  @override
  int get hashCode => hashValues(id, url);
}
