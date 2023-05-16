import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../provider/main_provider.dart';
class GridDummyScreen extends StatefulWidget {
  const GridDummyScreen({Key? key}) : super(key: key);

  @override
  State<GridDummyScreen> createState() => _GridDummyScreenState();
}

class _GridDummyScreenState extends State<GridDummyScreen> {
  @override
  Widget build(BuildContext context) {
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    Color color= listingprovider.lightMode? Color(0xFFF6F6F6): Colors.lightBlue.withOpacity(0.1);

    return StaggeredGridView.countBuilder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 6,
        crossAxisCount: 2,
        itemBuilder: (context, index) {

          return  Container(
            margin: EdgeInsets.all(5),
            height: MediaQuery.of(context).size.height* 0.22,
            decoration: BoxDecoration(
                color: color,

                borderRadius: BorderRadius.circular(18)
            ),

          );
        },
        staggeredTileBuilder: (context) => const StaggeredTile.fit(1));
  }
}
