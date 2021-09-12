import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'image_util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewGalleryScreen extends StatefulWidget {
  final List<ImageProvider> images;
  final int index;
  final String? heroTag;

  PhotoViewGalleryScreen(
      {Key? key, this.heroTag, this.images = const [], this.index = 0})
      : super(key: key);

  @override
  _PhotoViewGalleryScreenState createState() => _PhotoViewGalleryScreenState();
}

class _PhotoViewGalleryScreenState extends State<PhotoViewGalleryScreen> {
  int currentIndex = 0;
  late PageController controller;
  GlobalKey paperWidgetKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = PageController(initialPage: widget.index);
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
                child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: widget.images[index],
                  // imageProvider: NetworkImage(widget.images[index]),
                  heroAttributes: widget.heroTag!.isNotEmpty
                      ? PhotoViewHeroAttributes(tag: widget.heroTag!)
                      : null,
                );
              },
              itemCount: widget.images.length,
              // loadingChild: Container(),
              backgroundDecoration: null,
              pageController: controller,
              enableRotation: true,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            )),
          ),
          Positioned(
            //图片index显示
            top: MediaQuery.of(context).padding.top + 15,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("${currentIndex + 1}/${widget.images.length}",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          Positioned(
            //右上角关闭按钮
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: MediaQuery.of(context).padding.left + 24,
            child: IconButton(
              icon: Icon(
                Icons.save,
                color: Colors.green,
              ),
              onPressed: () async {},
            ),
          ),
          Positioned(
            //右上角关闭按钮
            right: 10,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
