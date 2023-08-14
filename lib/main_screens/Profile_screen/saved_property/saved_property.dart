import 'package:flutter/material.dart';
import '../../../utils/GridDummyScreen.dart';
import '../../Home_Screen/view_property.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import '../../../utils/empty_screen.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../../../utils/property_card.dart';
import '../../../provider/favourite_provider.dart';
import '../../../provider/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../provider/main_provider.dart';

class SavedProperties extends StatefulWidget {
  const SavedProperties({super.key});

  @override
  State<SavedProperties> createState() => _SavedPropertiesState();
}

class _SavedPropertiesState extends State<SavedProperties> {
  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    var favouriteprovider =
        Provider.of<FavoriteProvider>(context, listen: true);
    Color color = listingprovider.lightMode
        ? Color(0xFFF6F6F6)
        : Colors.lightBlue.withOpacity(0.1);
    Stream<QuerySnapshot> _popularNearYouStream = FirebaseFirestore.instance
        .collection('properties')
        // .where('pid', isEqualTo: authprovider.location)
        .snapshots();
    return Scaffold(
      backgroundColor: listingprovider.getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          "Saved Properties",
          style: TextStyle(color: listingprovider.getForegroundColor()),
        ),
        backgroundColor: listingprovider.getBackgroundColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: listingprovider.getForegroundColor(),
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          if (favouriteprovider.products.length == 0) EmptyScreen(),
          StaggeredGridView.countBuilder(
            staggeredTileBuilder: (context) => const StaggeredTile.fit(1),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            itemCount: favouriteprovider.products.length,
            itemBuilder: (context, index) {
              String pid = favouriteprovider.products[index];
              Stream<QuerySnapshot> _poductStream = FirebaseFirestore.instance
                  .collection('properties')
                  .where('pid', isEqualTo: pid)
                  .snapshots();
              return StreamBuilder<QuerySnapshot>(
                stream: _poductStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridDummyScreen();
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return EmptyScreen();
                  }
                  QueryDocumentSnapshot<Object?> product =
                      snapshot.data!.docs.first;

                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewProperty(product: product)));
                      },
                      child: PropertyCard(
                        product: product,
                        index: index,
                      ));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
