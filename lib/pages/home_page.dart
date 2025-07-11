import 'package:ente_assignment/components/photo_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/asset_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool permissionDenied = false;
  int photoCount = 0;
  List<AssetEntity> entities = [];
  List<AssetModel> assetModels = [];

  void _loadPhotos() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    debugPrint(ps.toString());
    if (ps.isAuth || ps.hasAccess) {
      List<AssetEntity> e = await PhotoManager.getAssetListPaged(
        page: 0,
        pageCount: 80,
      );
      int count = await PhotoManager.getAssetCount();
      setState(() {
        photoCount = count;
        entities = e;
        assetModels = e.map((entity) => AssetModel(entity: entity)).toList();
      });
      debugPrint("$photoCount");
    } else {
      setState(() {
        permissionDenied = true;
      });
    }
  }

  @override
  void initState() {
    _loadPhotos();
    super.initState();
  }

  Map<String, List<AssetModel>> get assetsGroupedByDay {
    Map<String, List<AssetModel>> grouped = {};
    final now = DateTime.now();
    final todayKey = 'Today';
    final yesterdayKey = 'Yesterday';
    final weekdayRangeKey = 'Monday-Friday';
    for (var model in assetModels) {
      final date = model.entity?.createDateTime;
      if (date != null) {
        String key;
        final diff = now.difference(DateTime(date.year, date.month, date.day));
        if (diff.inDays == 0) {
          key = todayKey;
        } else if (diff.inDays == 1) {
          key = yesterdayKey;
        } else if (diff.inDays <= now.weekday && diff.inDays <= 6 && diff.inDays > 1) {
          key = weekdayRangeKey;
        } else {
          key = _formatFullDate(date);
        }
        grouped.putIfAbsent(key, () => []).add(model);
      }
    }
    final ordered = <String, List<AssetModel>>{};
    for (var k in [todayKey, yesterdayKey, weekdayRangeKey]) {
      if (grouped.containsKey(k)) ordered[k] = grouped[k]!;
    }
    final otherKeys = grouped.keys.where((k) => k != todayKey && k != yesterdayKey && k != weekdayRangeKey).toList();
    otherKeys.sort((a, b) {
      final aDate = _parseFullDate(a);
      final bDate = _parseFullDate(b);
      return bDate.compareTo(aDate);
    });
    for (var k in otherKeys) {
      ordered[k] = grouped[k]!;
    }
    return ordered;
  }

  String _formatFullDate(DateTime date) {
    final weekday = _weekdayName(date.weekday);
    final day = date.day.toString().padLeft(2, '0');
    final month = _monthName(date.month);
    final year = date.year;
    return "$weekday, $day $month $year";
  }

  DateTime _parseFullDate(String s) {
    final parts = s.split(', ');
    if (parts.length != 2) return DateTime(1970);
    final dateParts = parts[1].split(' ');
    if (dateParts.length != 3) return DateTime(1970);
    final day = int.tryParse(dateParts[0]) ?? 1;
    final month = _monthNumber(dateParts[1]);
    final year = int.tryParse(dateParts[2]) ?? 1970;
    return DateTime(year, month, day);
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return weekdays[weekday];
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  int _monthNumber(String name) {
    const months = {
      'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5, 'June': 6,
      'July': 7, 'August': 8, 'September': 9, 'October': 10, 'November': 11, 'December': 12
    };
    return months[name] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ente",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.add_to_photos)),
        ],
      ),
      body: assetModels.isNotEmpty
          ? ListView(
              children: assetsGroupedByDay.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        entry.key,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    GridView.builder(
                      key: ValueKey(entry.key),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        final model = entry.value[index];
                        return PhotoTile(
                          key: ValueKey(model.entity?.id),
                          model: model,
                          select: () {
                            model.toggleSelection();
                            setState(() {});
                          },
                          deselect: () {
                            model.toggleSelection();
                            setState(() {});
                          },
                          isAnySelected: assetModels.any((m) => m.isSelected),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            )
          : Center(child: Text("No Photos :(")),
    );
  }
}
