import 'dart:io';
import './ion_mime.dart';

class IonResponse {
  HttpResponse original;
  var srv;

  IonResponse(o, s) {
    original = o;
    srv = s;
  }

  send(data){
    if (data is File) {
      var str = data.readAsBytesSync();
      original.headers.contentType = ion_mime(data.path);
      original.add(str);
    } else {
      original.write(data);
    }
  }

  setCookie(name, val) {
    original.headers.set("Set-Cookie", "$name = $val");
  }

  deleteCookie(name) {
    original.headers.set(
        "Set-Cookie", "$name = del; expires=Thu, 01 Jan 1970 00:00:00 GMT");
  }

  redirect(path) {
    print("REDIRECTING TO: $path");
    original.statusCode = 308;
    original.headers.set("Location", "$path");
  }

  render(path, [Map data]) {
    var SUPER = {
      "ION.version": "0.4b"
    };
    if(data is Map){
      SUPER.addAll(data);
    };
    var prefix = srv.get("paths").containsKey("render")
        ? srv.get("paths")["render"]
        : "";
    var f = File(prefix + path);
    original.headers.contentType =
        ContentType("text", "html", charset: "UTF-8");
    var content = f.readAsStringSync();
    var response = content.replaceAllMapped(
        RegExp(r'<%([^%>]+)?%>'),
        (match) => SUPER.containsKey(match.group(1).trim())
            ? SUPER[match.group(1).trim()]
            : match.group(0));
    response = response
        .replaceAllMapped(RegExp(r'<{([\s\S]*?)?}>', multiLine: true), (match) {
      var code =
          match.group(1).replaceAllMapped(RegExp(r'\$\((.*?)\)'), (match) {
        if (match.group(1).contains("<") && match.group(1).contains(">")) {
          return "document.createElement('${match.group(1).substring(2, match.group(1).length - 2)}')";
        } else if (match.group(1).contains("(")) {
          return "document.addEventListener('DOMContentLoaded', ()";
        } else {
          return "document.querySelector(${match.group(1)})";
        }
      });
      return "<script>$code</script>";
    });
    return original.write(response);
  }
}
