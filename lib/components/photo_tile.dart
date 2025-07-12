import 'dart:io';

import 'package:animations/animations.dart';
import 'package:ente_assignment/models/asset_model.dart';
import 'package:ente_assignment/pages/photo_view_page.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoTile extends StatelessWidget {
  final AssetModel model;
  final Function select;
  final Function deselect;
  final bool isAnySelected;
  const PhotoTile({
    super.key,
    required this.model,
    required this.select,
    required this.deselect,
    this.isAnySelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: model.entity?.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          return OpenContainer(
            closedElevation: 0,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            openBuilder: (context, action) => PhotoViewPage(model: model),
            closedBuilder: (BuildContext context, Function openContainer) =>
                Stack(
                  children: [
                    GestureDetector(
                      onLongPress: () => select(),
                      onTap: () {
                        if (model.isSelected) {
                          deselect();
                        } else if (isAnySelected) {
                          select();
                        } else {
                          openContainer();
                        }
                      },
                      child: Image.file(
                        snapshot.data!,
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    if (model.isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white.withAlpha(200),
                          size: 24,
                        ),
                      ),
                    if (isAnySelected && !model.isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.white.withAlpha(200),
                          size: 24,
                        ),
                      ),
                  ],
                ),
          );
        } else {
          return Container(color: Colors.grey[300]);
        }
      },
    );
  }
}
