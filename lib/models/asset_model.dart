import 'package:photo_manager/photo_manager.dart';

class AssetModel {
  AssetEntity? entity;
  bool isSelected = false;
  bool isFavourite = false;

  AssetModel({this.entity});
  AssetModel.fromEntity(this.entity) {
    isSelected = false;
    isFavourite = false;
  }

  void toggleSelection() {
    isSelected = !isSelected;
  }

  void toggleFavourite() {
    isFavourite = !isFavourite;
  }
}
