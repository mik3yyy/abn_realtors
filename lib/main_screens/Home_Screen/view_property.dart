import 'dart:ffi';

import 'package:abn_realtors/main_screens/messages_screen/chart_screen.dart';
import 'package:abn_realtors/utils/GridDummyScreen.dart';
import 'package:abn_realtors/utils/property_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../../provider/auth_provider.dart';
import '../../provider/main_provider.dart';
import '../../settings/constants.dart';
import 'package:intl/intl.dart';

class ViewProperty extends StatefulWidget {
  const ViewProperty({Key? key, required this.product}) : super(key: key);
  final QueryDocumentSnapshot<Object?> product;

  @override
  State<ViewProperty> createState() => _ViewPropertyState();
}

class _ViewPropertyState extends State<ViewProperty> {
  PageController pageController = PageController(initialPage: 0);
  int currentpage = 0;

  final oCcy = NumberFormat("#,##0.00", "en_US");
  CollectionReference customers =
      FirebaseFirestore.instance.collection('agents');
  DocumentSnapshot<Object?>? agent;
  String? agentImage;
  void getAgentInfo() async {
    try {
      var user = await customers.doc(widget.product["uid"]).get();

      setState(() {
        agent = user;
        agentImage = agent!["image"];
      });
    } catch (e) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAgentInfo();
  }

  double sqm = 0;
  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    try {
      double breath = double.parse(widget.product["breath"]);
      double length = double.parse(widget.product["length"]);

      sqm = breath * length;
    } catch (e) {}

    final Stream<QuerySnapshot> _similarProductStream = FirebaseFirestore
        .instance
        .collection('properties')
        .where('Category', isEqualTo: widget.product["Category"])
        .snapshots();

    String price = widget.product["price"];

    if (price.length > 9) {
      price = price.substring(0, price.length - 9) + "B";
    } else if (price.length > 6) {
      price = price.substring(0, price.length - 6) + "M";
    } else if (price.length > 3) {
      price = price.substring(0, price.length - 3) + "K";
    }
    return Scaffold(
      backgroundColor: listingprovider.getBackgroundColor(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: listingprovider.getBackgroundColor(),
        leadingWidth: 70,
        leading: Center(
          child: Container(
            // margin: EdgeInsets.only(left: 10),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.chevron_left,
                    color: Constants.primaryColor,
                  )),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    // margin: EdgeInsets.only(top: 20),
                    height: MediaQuery.of(context).size.width * 0.8,
                    width: MediaQuery.of(context).size.width,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),

                    child: PageView.builder(
                      controller: pageController,
                      itemCount: widget.product["imageUrls"].length,
                      onPageChanged: (int value) {
                        print(value);
                        setState(() {
                          currentpage = value;
                        });
                      },
                      itemBuilder: (context, index) {
                        // transformationController: TransformationController();

                        return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              // image: DecorationImage(
                              //   fit: BoxFit.contain,
                              //   image: FileImage(File(postprovider.imageFiles[index]),
                              //   ),
                              // ),
                            ),
                            child: PinchZoom(
                                resetDuration:
                                    const Duration(milliseconds: 100),
                                // maxScale: 2.5,
                                onZoomStart: () {
                                  print('Start zooming');
                                },
                                onZoomEnd: () {
                                  print('Stop zooming');
                                },
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      widget.product["imageUrls"][index],
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        return Container(
                                          decoration:
                                              BoxDecoration(color: Colors.grey),
                                          child: child,
                                        );
                                      },
                                      errorBuilder: (context, object, error) {
                                        return Container(
                                          decoration:
                                              BoxDecoration(color: Colors.grey),
                                        );
                                      },
                                    ))));
                      },
                    ),
                  ),
                ],
              ),
              if (widget.product["imageUrls"].length > 1)
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: widget.product["imageUrls"].length,
                      effect: JumpingDotEffect(
                        radius: 10,
                        activeDotColor: Constants.primaryColor,
                        dotColor: listingprovider.lightMode
                            ? Constants.greyColor
                            : listingprovider.getForegroundColor(),
                        dotHeight: 7,
                        dotWidth: 7,
                        jumpScale: .7,
                        verticalOffset: 15,
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.product["title"],
                style: TextStyle(
                    color: listingprovider.getForegroundColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),
                        Text(
                          "  " + widget.product["lga"] + ", ",
                          style: TextStyle(
                              color: listingprovider.getForegroundColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          widget.product["state"],
                          style: TextStyle(
                              color: listingprovider.getForegroundColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                              color: Color(0xFFF1FBFF),
                              borderRadius: BorderRadius.circular(5)),
                          // width: 30,x
                          child: Center(
                            child: Text(
                              "₦ " +
                                  oCcy.format(
                                      double.parse(widget.product["price"])),
                              style: TextStyle(color: Constants.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //  RAW LAND
              if (widget.product["Category"] == "Raw land")
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Row(
                          //   children: [
                          //     // Icon(Icons.landscape, size: 14, color: Colors.grey,),
                          //     Text(widget.product["length"]+ "m",
                          //       style: TextStyle(
                          //           color: listingprovider.getForegroundColor()
                          //       ),
                          //
                          //     ),
                          //   ],
                          // ),
                          Text(
                            sqm.toString() + " sqm",
                            style: TextStyle(
                                color: listingprovider.getForegroundColor()),
                          ),
                          // Row(
                          //   children: [
                          //     // Icon(FontAwesomeIcons.toilet, size: 14, color: Colors.grey,),
                          //     Text(widget.product["breath"]+ "m",
                          //       style: TextStyle(
                          //           color: listingprovider.getForegroundColor()
                          //       ),),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              //FLOORS, TOILET, BEDROOMS
              if (widget.product["Category"] == "Terrace" ||
                  widget.product["Category"] == "Semi-detached" ||
                  widget.product["Category"] == "Building" ||
                  widget.product["Category"] == "Apartment" ||
                  widget.product["Category"] == "Mansion" ||
                  widget.product["Category"] == "Penthouse")
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bedroom_child,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(
                                widget.product["bedroom"],
                                style: TextStyle(
                                    color:
                                        listingprovider.getForegroundColor()),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.toilet,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(
                                widget.product["toilet"],
                                style: TextStyle(
                                    color:
                                        listingprovider.getForegroundColor()),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.house,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(
                                widget.product["floors"],
                                style: TextStyle(
                                    color:
                                        listingprovider.getForegroundColor()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              if (widget.product["Category"] == "Office Space")
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.room_preferences,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(
                                widget.product["rooms"],
                                style: TextStyle(
                                    color:
                                        listingprovider.getForegroundColor()),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.toilet,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(
                                widget.product["toilet"],
                                style: TextStyle(
                                    color:
                                        listingprovider.getForegroundColor()),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.house,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(
                                widget.product["floors"],
                                style: TextStyle(
                                    color:
                                        listingprovider.getForegroundColor()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),

              //LESTING AGENT
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lesting agent",
                    style: TextStyle(
                        color: listingprovider.getForegroundColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: agentImage == null
                          ? Container(
                              width: 10,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    agentImage!,
                                    fit: BoxFit.fill,
                                    loadingBuilder: (context, child, loading) {
                                      return Container(
                                        decoration:
                                            BoxDecoration(color: Colors.grey),
                                        child: child,
                                      );
                                    },
                                    errorBuilder: (context, object, error) {
                                      return Container(
                                        decoration:
                                            BoxDecoration(color: Colors.grey),
                                      );
                                    },
                                  )),
                            ),
                      title: agent != null
                          ? Text(
                              agent!["fullname"],
                              style: TextStyle(
                                color: listingprovider.getForegroundColor(),
                              ),
                            )
                          : Text(""),
                      subtitle:
                          agent != null && agent!["email"] != authprovider.email
                              ? Text(
                                  "Agent in charge",
                                  style: TextStyle(
                                    color: listingprovider.getForegroundColor(),
                                  ),
                                )
                              : Text("I am in charge"),
                      trailing: agent == null
                          ? Container(
                              height: 2,
                              width: 2,
                            )
                          : agent!["email"] == authprovider.email
                              ? Container(
                                  height: 2,
                                  width: 2,
                                )
                              : Container(
                                  // margin: EdgeInsets.only(left: 10),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlueAccent.shade100,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                          user: agent!)));
                                        },
                                        icon: Icon(
                                          Icons.messenger_outline,
                                          color: Constants.primaryColor,
                                        )),
                                  ),
                                ),
                    ),
                  ),
                  if (agent != null && agent!["email"] != authprovider.email)
                    MaterialButton(
                      onPressed: () {},
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Constants.primaryColor,
                            border: Border.all(color: Constants.primaryColor),
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Book now",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),

              Text(
                "Description",
                style: TextStyle(
                    color: listingprovider.getForegroundColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    widget.product["description"],
                    style: TextStyle(
                      color: listingprovider.getForegroundColor(),
                    ),
                  )),
              SizedBox(
                height: 20,
              ),
              Text(
                "Similar ",
                style: TextStyle(
                    color: listingprovider.getForegroundColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _similarProductStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return GridDummyScreen();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridDummyScreen();
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text(
                      'This category \n\n has no items yet !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Acme',
                          letterSpacing: 1.5),
                    ));
                  }
                  List<QueryDocumentSnapshot<Object?>> products =
                      snapshot.data!.docs;

                  return StaggeredGridView.countBuilder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      crossAxisCount: 2,
                      itemBuilder: (context, index) {
                        String price = '';

                        List<String> ListPrice =
                            products[index]["price"].toString().split('.');
                        String oldPrice = ListPrice[0];
                        if (oldPrice.length > 9) {
                          oldPrice =
                              oldPrice.substring(0, oldPrice.length - 9) + "B";
                        } else if (oldPrice.length > 6) {
                          oldPrice =
                              oldPrice.substring(0, oldPrice.length - 6) + "M";
                        } else if (oldPrice.length > 3) {
                          oldPrice =
                              oldPrice.substring(0, oldPrice.length - 3) + "K";
                        }
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
                          ),
                        );
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
  }
}
