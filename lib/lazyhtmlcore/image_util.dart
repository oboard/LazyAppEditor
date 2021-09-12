import 'dart:async';
import 'dart:ui';
import 'package:flutter/painting.dart';

class ImageUtils{
  static Future<Image> loadImageByProvider(
      ImageProvider provider, {
        ImageConfiguration config = ImageConfiguration.empty,
      }) async {
    Completer<Image> completer = Completer<Image>(); //完成的回调
    late ImageStreamListener listener;
    ImageStream stream = provider.resolve(config); //获取图片流
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
//监听
      final Image image = frame.image;
      completer.complete(image); //完成
      stream.removeListener(listener); //移除监听
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }

}
