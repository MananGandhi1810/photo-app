import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoTile extends StatelessWidget {
  final AssetEntity entity;
  const PhotoTile({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: entity.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          return Image.file(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return Container(
            color: Colors.grey[300],
          );
        }
      },
    );
  }
}
