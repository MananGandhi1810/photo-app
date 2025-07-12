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
        } else if (diff.inDays <= now.weekday &&
            diff.inDays <= 6 &&
            diff.inDays > 1) {
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
    final otherKeys = grouped.keys
        .where(
          (k) => k != todayKey && k != yesterdayKey && k != weekdayRangeKey,
        )
        .toList();
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
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday];
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  int _monthNumber(String name) {
    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
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
          ? SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ListView(
                    children: assetsGroupedByDay.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              entry.key,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GridView.builder(
                            key: ValueKey(entry.key),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
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
                                isAnySelected: assetModels.any(
                                  (m) => m.isSelected,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  if (assetModels.any((m) => m.isSelected))
                    AnimatedSlide(
                      duration: Duration(milliseconds: 300),
                      offset: Offset(0, 0),
                      curve: Curves.easeOut,
                      child: _SelectionBottomSheet(
                        selectedCount: assetModels
                            .where((m) => m.isSelected)
                            .length,
                        onSelectAll: () {
                          setState(() {
                            for (var m in assetModels) {
                              m.isSelected = true;
                            }
                          });
                        },
                        onDeselectAll: () {
                          setState(() {
                            for (var m in assetModels) {
                              m.isSelected = false;
                            }
                          });
                        },
                        onDelete: () {
                          setState(() {
                            assetModels.removeWhere((m) => m.isSelected);
                          });
                        },
                      ),
                    ),
                ],
              ),
            )
          : Center(
              child: permissionDenied
                  ? Text("Permission Denied")
                  : CircularProgressIndicator(),
            ),
    );
  }
}

class _SelectionBottomSheet extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final VoidCallback onDelete;
  // Add more callbacks as needed

  const _SelectionBottomSheet({
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: 320,
        ),
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onSelectAll,
                  icon: Icon(Icons.done_all, color: Color(0xFF7C3AED)),
                  label: Text('Select All', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$selectedCount selected',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black87),
                  onPressed: onDeselectAll,
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 16,
              children: [
                _ActionButton(icon: Icons.photo_album, label: 'Add to album'),
                _ActionButton(icon: Icons.favorite_border, label: 'Favourite'),
                _ActionButton(icon: Icons.download, label: 'Download'),
                _ActionButton(icon: Icons.visibility_off, label: 'Hide'),
                _ActionButton(icon: Icons.archive, label: 'Archive'),
                _ActionButton(icon: Icons.edit, label: 'Edit time'),
                _ActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: onDelete,
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_upward, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color ?? Colors.black, size: 32),
          ),
          SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
