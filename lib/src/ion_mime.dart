import "dart:io";

ContentType ion_mime(String path) {
  var p;
  var s;

  switch (path.split('.').last) {
    case "png":
      p = "image";
      s = "png";
      break;

    case "jpg":
    case "jpeg":
      p = "image";
      s = "jpg";
      break;

    case "bmp":
      p = "image";
      s = "bmp";
      break;

    case "gif":
      p = "image";
      s = "gif";
      break;

    case "tif":
    case "tiff":
      p = "image";
      s = "tiff";
      break;

    case "ico":
      p = "image";
      s = "x-ico";
      break;

    case "htm":
    case "html":
      p = "text";
      s = "html";
      break;

    case "css":
      p = "text";
      s = "css";
      break;

    case "csv":
      p = "text";
      s = "csv";
      break;

    case "xml":
      p = "application";
      s = "xml";
      break;

    case "js":
      p = "application";
      s = "javascript";
      break;

    case "json":
      p = "application";
      s = "json";
      break;

    case "zip":
      p = "application";
      s = "zip";
      break;

    case "webp":
      p = "image";
      s = "webp";
      break;
    
    case "weba":
      p = "audio";
      s = "webm";
      break;

    case "webm":
      p = "video";
      s = "webm";
      break;
  }

  return ContentType(p, s);
}
