import "package:ion/ion.dart";
import "dart:io";

void main() {
  //pass a port
  var app = Ion(80);


  app.on("/", (req, res) {
    res.send("Welcome on my page!");
  });

  app.on("/contact", (req, res) {
    var f = File("./static/contact.html");

    res.send(f);
  });

}