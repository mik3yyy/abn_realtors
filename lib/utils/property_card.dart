import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../provider/main_provider.dart';
import '../settings/constants.dart';

class PropertyCard extends StatefulWidget {
  const PropertyCard({Key? key, required this.product, required this.index})
      : super(key: key);

  final QueryDocumentSnapshot<Object?> product;
  final int index;
  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    Color color = listingprovider.lightMode
        ? Color(0xFFF6F6F6)
        : Colors.lightBlue.withOpacity(0.1);
    String price = widget.product["price"];

    if (price.length > 9) {
      price = price.substring(0, price.length - 9) + "B";
    } else if (price.length > 6) {
      price = price.substring(0, price.length - 6) + "M";
    } else if (price.length > 3) {
      price = price.substring(0, price.length - 3) + "K";
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: PhysicalModel(
        elevation: 0,

        // shadowColor:
        //     listingprovider.lightMode ? Color(0xFF000000) : Color(0xFF303134),
        // borderRadius: BorderRadius.circular(5),
        color: listingprovider.getBackgroundColor(),
        child: Container(
          // margin: EdgeInsets.all(5),
          height: 260,
          width: 200,
          decoration: BoxDecoration(
              color: listingprovider.getBackgroundColor(),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                height: 165,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(5)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image(
                    image: NetworkImage(widget.product["imageUrls"][0]),
                    fit: BoxFit.fill,
                    loadingBuilder: (context, child, loading) {
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
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Text(
                      widget.product["title"].toString().length < 15
                          ? widget.product["title"]
                          : widget.product["title"]
                                  .toString()
                                  .substring(0, 15) +
                              "...",
                      style: TextStyle(
                          color: listingprovider.getForegroundColor(),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: listingprovider.getForegroundColor(),
                    ),
                    Text(
                      widget.product["lga"] + ", ",
                      style: TextStyle(
                          color: listingprovider.getForegroundColor(),
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      widget.product["state"],
                      style: TextStyle(
                          color: listingprovider.getForegroundColor(),
                          fontSize: 10,
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
                          "₦ " + price,
                          style: TextStyle(color: Constants.primaryColor),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: listingprovider.getForegroundColor(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
