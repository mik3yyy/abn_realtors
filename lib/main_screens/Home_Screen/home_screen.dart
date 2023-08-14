import 'package:abn_realtors/main_screens/Home_Screen/view_property.dart';
import 'package:abn_realtors/settings/constants.dart';
import 'package:abn_realtors/utils/ListDummyScreen.dart';
import 'package:abn_realtors/utils/dummy_screen.dart';
import 'package:abn_realtors/utils/empty_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../../provider/auth_provider.dart';
import '../../provider/main_provider.dart';
import '../../utils/GridDummyScreen.dart';
import '../../utils/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool result = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checker();
  }

  void checker() async {
    result = await InternetConnectionChecker().hasConnection;
    setState(() {});
  }

  bool online = true;

  bool popularNearYou = true;

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    Stream<QuerySnapshot> _popularNearYouStream = FirebaseFirestore.instance
        .collection('properties')
        .where('state', isEqualTo: authprovider.location)
        .snapshots();
    Stream<QuerySnapshot> _recommendedForYouStream =
        FirebaseFirestore.instance.collection('properties').snapshots();

    return ConnectivityWidget(
      showOfflineBanner: false,
      builder: (context, isOnline) {
        // print(isOnline);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Add Your Code here.
          if (online != isOnline && isOnline == true) {
            setState(() {
              online = isOnline;
            });
          } else if (online != isOnline && isOnline == false) {
            setState(() {
              online = isOnline;
            });
          }
        });
        return Scaffold(
          backgroundColor: listingprovider.getBackgroundColor(),
          appBar: authprovider.email.isNotEmpty
              ? AppBar(
                  backgroundColor: listingprovider.getBackgroundColor(),
                  elevation: 0,
                  // leadingWidth: 70,
                  leading: IconButton(
                    onPressed: () {},
                    icon: Container(
                      // margin: EdgeInsets.only(left: 10),
                      width: 40,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.lightBlueAccent.shade100,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Icon(
                          Icons.notifications_none,
                          color: Constants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  title: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        Text(
                          authprovider.fullname,
                          style: TextStyle(
                            fontSize: 15,
                            color: listingprovider.getForegroundColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  actions: [
                    Container(
                      padding: EdgeInsets.all(5),
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                          color: listingprovider.getBackgroundColor(),
                          borderRadius: BorderRadius.circular(40)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            authprovider.imageFile,
                            fit: BoxFit.fill,
                            loadingBuilder: (context, child, loadingProgress) {
                              return Container(
                                decoration: BoxDecoration(color: Colors.grey),
                                child: child,
                              );
                            },
                            errorBuilder: (context, object, error) {
                              return Container(
                                decoration: BoxDecoration(color: Colors.grey),
                              );
                            },
                          )

                          // Image.network(authprovider.imageFile, fit: BoxFit.fill,),

                          ),
                    ),
                    Container(
                      width: 10,
                    ),
                  ],
                )
              : AppBar(
                  backgroundColor: listingprovider.getBackgroundColor(),
                  elevation: 0,
                  title: Image.asset('assets/images/abn_logo.png'),
                  actions: [
                    SizedBox(
                      width: 70,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'sign in',
                          style: TextStyle(
                            color: Constants.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Featured properties",
                    style: TextStyle(
                        color: listingprovider.getForegroundColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: MediaQuery.of(context).size.width,
                    height: 148,
                    decoration: BoxDecoration(
                        color: listingprovider.getForegroundColor(),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  if (popularNearYou)
                    Text(
                      "Popular near you",
                      style: TextStyle(
                          color: listingprovider.getForegroundColor(),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  if (popularNearYou)
                    StreamBuilder<QuerySnapshot>(
                      stream: _popularNearYouStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return ListDummyScreen();
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListDummyScreen();
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          setState(() {
                            popularNearYou = true;
                          });
                          return EmptyScreen();
                        }
                        List<QueryDocumentSnapshot<Object?>> products =
                            snapshot.data!.docs;
                        // WidgetsBinding.instance.addPostFrameCallback((_){
                        //
                        //   // Add Your Code here.
                        //   setState(() {
                        //     popularNearYou =true;
                        //   });
                        //
                        // });
                        return Container(
                          height: 270,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                List<String> ListPrice = products[index]
                                        ["price"]
                                    .toString()
                                    .split('.');
                                String oldPrice = ListPrice[0];
                                if (oldPrice.length > 9) {
                                  oldPrice = oldPrice.substring(
                                          0, oldPrice.length - 9) +
                                      "B";
                                } else if (oldPrice.length > 6) {
                                  oldPrice = oldPrice.substring(
                                          0, oldPrice.length - 6) +
                                      "M";
                                } else if (oldPrice.length > 3) {
                                  oldPrice = oldPrice.substring(
                                          0, oldPrice.length - 3) +
                                      "K";
                                }

                                return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewProperty(
                                                      product:
                                                          products[index])));
                                    },
                                    child: PropertyCard(
                                      product: products[index],
                                      index: index,
                                    ));
                              }),
                        );
                      },
                    ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Recommended for you",
                    style: TextStyle(
                        color: listingprovider.getForegroundColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _recommendedForYouStream,
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
                      List<QueryDocumentSnapshot<Object?>> products =
                          snapshot.data!.docs;

                      return StaggeredGridView.countBuilder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          crossAxisCount: 2,
                          itemBuilder: (context, index) {
                            List<String> ListPrice =
                                products[index]["price"].toString().split('.');
                            String oldPrice = ListPrice[0];
                            if (oldPrice.length > 9) {
                              oldPrice =
                                  oldPrice.substring(0, oldPrice.length - 9) +
                                      "B";
                            } else if (oldPrice.length > 6) {
                              oldPrice =
                                  oldPrice.substring(0, oldPrice.length - 6) +
                                      "M";
                            } else if (oldPrice.length > 3) {
                              oldPrice =
                                  oldPrice.substring(0, oldPrice.length - 3) +
                                      "K";
                            }
                            // print(products[index].data());

                            return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewProperty(
                                              product: products[index])));
                                },
                                child: PropertyCard(
                                  product: products[index],
                                  index: index,
                                ));
                          },
                          staggeredTileBuilder: (context) =>
                              const StaggeredTile.fit(1));
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
