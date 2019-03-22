library ion;

import 'dart:io';
import 'src/ion_sock.dart';
import 'src/ion_req.dart';
import 'src/ion_res.dart';

class Ion {
  int port;
  InternetAddress ip;
  HttpServer srv;
  Map data = {};
  Map paths = {};
  IonWebsocketController ws_ctl;
  Map ws_cfg = {
    "ws_cnx": null,
    "ws_wlc": null,
  };
  Map cfg;
  bool production;

  Ion(p, {Map this.cfg, bool this.production = false}) {
    _init(p);
  }

  _init(p) async {
    port = p;
    ip = InternetAddress.anyIPv4;

    print(ip);
    srv = await HttpServer.bind(ip, port);

    //var ctx = SecurityContext();

    await for (HttpRequest req in srv) {
      var res = req.response;
      var ion_res = IonResponse(res, this);
      var ion_req = IonRequest(req);
      await ion_req.init();

      var path = req.uri.toString().split("?")[0];

      if (!handle(path, ion_req, ion_res)) {
        var prefix =
            get("paths").containsKey("static") ? get("paths")["static"] : "";
        var file = File(prefix + path);
        if (file.existsSync()) {
          ion_res.send(file);
        } else if (path == ws_cfg["ws_cnx"]) {
          var ws = await WebSocketTransformer.upgrade(req);
          ws_ctl.add(ws);
          if (ws_cfg["ws_wlc"] is Function) {
            ws_cfg["ws_wlc"](ws);
          }
        } else {
          print("Cannot ${req.method}: $path");
          ion_res.send("Cannot ${req.method}: $path");
        }
      }

      res.close();
    }
  }

  handle(path, req, res) {
    var isHandled = false;
    paths.forEach((key, value) {
      if (key == path) {
        value(req, res);
        isHandled = true;
        return true;
      } else if (key.contains(":")) {
        var params = {};
        var segments = key.split("/");
        var param_indicies = segments.map((el) => el.startsWith(":")).toList();

        var path_segments = path.split("/");

        var isValid = true;

        for (int i = 0; i < param_indicies.length; i++) {
          bool isParam = param_indicies[i];

          if (!isParam) {
            if (segments[i] != path_segments[i]) {
              isValid = false;
              break;
            }
          } else {
            String sg = segments[i];
            params[sg.replaceFirst(r":", "")] = path_segments[i];
          }
        }
        if (isValid) {
          req.setParams(params);
          value(req, res);

          isHandled = true;
          return true;
        }
      }
    });

    return isHandled;
  }

  on(uri, fn) {
    paths[uri] = fn;
  }

  set(key, value) {
    data[key] = value;
  }

  get(key) {
    return data[key];
  }

  ws([String url, Function fn]) {
    if (ws_ctl == null) {
      ws_ctl = IonWebsocketController();
    }

    if (url is String) {
      ws_cfg["ws_cnx"] = url;
      if (fn is Function) {
        ws_cfg["ws_wlc"] = fn;
      }
    }
    return ws_ctl;
  }
}
