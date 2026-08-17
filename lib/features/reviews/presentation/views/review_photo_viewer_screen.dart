import 'dart:io';
import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class ReviewPhotoViewerScreen extends StatelessWidget {
  final String photoUrl;

  const ReviewPhotoViewerScreen({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textHigh),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: photoUrl.startsWith('http')
              ? Image.network(photoUrl, fit: BoxFit.contain)
              : Image.file(File(photoUrl), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
