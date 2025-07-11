import 'package:ente_assignment/components/photo_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool permissionDenied = false;
  int photoCount = 0;
  List<AssetEntity> entities = [];

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
      body: entities.isNotEmpty
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: entities.length,
              itemBuilder: (context, index) {
                return PhotoTile(entity: entities[index]);
              },
            )
          : Center(child: Text("No Photos :(")),
    );
  }
}
