import 'dart:io';
import 'dart:convert';

class IonRequest {
  HttpRequest original;
  Map qs;
  Map body;
  List<Cookie> cookies;
  Map params;
  String url;
  Uri uri;
  String post;

  IonRequest(HttpRequest o) {
    original = o;
    qs = o.uri.queryParameters;
    cookies = o.cookies;
    uri = o.uri;
    url = o.uri.toString();
  }

  init() async {
    post = await original.cast<List<int>>().transform(Utf8Decoder()).join();
    print(post);
    body = Uri(query: post).queryParameters;
  }

  setParams(p) {
    params = p;
  }
}
