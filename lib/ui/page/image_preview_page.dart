import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreviewPage extends StatefulWidget {
  final String path;

  const ImagePreviewPage({super.key, required this.path});

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  double _verticalDragOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: GestureDetector(
          onVerticalDragUpdate: (details) {
            // Update the vertical drag offset
            setState(() {
              _verticalDragOffset += details.delta.dy;
            });
          },
          onVerticalDragEnd: (details) {
            // Check if the drag is beyond the threshold to close
            if (_verticalDragOffset.abs() > 150) {
              Navigator.of(context).pop();
            } else {
              // Reset the offset if not beyond threshold
              setState(() {
                _verticalDragOffset = 0.0;
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, _verticalDragOffset, 0),
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  maxScale: PhotoViewComputedScale.contained * 2.0,
                  minScale: PhotoViewComputedScale.contained * 1.0,
                  initialScale: PhotoViewComputedScale.contained * 1.0,
                  imageProvider: FileImage(File(widget.path)),
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.path),
                  onTapUp: (_, __, ___) {
                    Navigator.of(context).pop();
                  },
                );
              },
              itemCount: 1,
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
            ),
          ),
        ));
  }
}
