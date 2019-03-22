import "dart:io";
import "dart:convert";

class IonWebsocketController {
  var sockets = <WebSocket>[];
  var behaviour = {};

  send(data) {
    sockets.forEach((ws) {
      ws.add(data);
    });
  }

  add(WebSocket ws) {
    print("WebSocket Connected");
    sockets.add(ws);

    var str = ws.listen(onMessage(ws));
    str.onDone(doneHandler(ws));
  }

  on(handler, fn) {
    behaviour[handler] = fn;
  }

  Function onMessage(ws) {
    return (message) {
      var msg = json.decode(message);

      behaviour.forEach((k, v) {
        if (msg["u"] == k) {
          v(msg["m"], ws);
          return;
        }
      });
    };
  }

  Function doneHandler(ws) {
    return () {
      sockets.remove(ws);
      print("WebSocket Disconnected");
    };
  }

  Function errorHandler(e, ws) {
    return () {
      print("WS Error Ocurred: $e");
      sockets.remove(ws);
    };
  }
}
