import 'dart:io';

import 'package:ente_assignment/models/asset_model.dart';
import 'package:flutter/material.dart';

class PhotoViewPage extends StatelessWidget {
  final AssetModel model;
  const PhotoViewPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FutureBuilder<File?>(
          future: model.entity?.file,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                snapshot.data != null) {
              return Image.file(snapshot.data!);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}