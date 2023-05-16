import 'package:abn_realtors/settings/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';
import '../../Agents_main_screens/Agent_Home_Screen/view_property.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    final Stream<QuerySnapshot> _popularNearYouStream = FirebaseFirestore.instance
        .collection('properties')
        .where( 'state' , isEqualTo: authprovider.location)
        .snapshots();
    final Stream<QuerySnapshot> _recommendedForYouStream = FirebaseFirestore.instance
        .collection('properties')
        .snapshots();
    return Scaffold(
      backgroundColor: listingprovider.getBackgroundColor(),
      appBar:authprovider.email.isNotEmpty? AppBar(
        backgroundColor: listingprovider.getBackgroundColor(),
        elevation: 0,
        // leadingWidth: 70,
        leading: IconButton(
          onPressed: (){},
          icon: Container(
            // margin: EdgeInsets.only(left: 10),
            width: 40,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                borderRadius: BorderRadius.circular(10)

            ),
            child: Center(
              child: Icon(Icons.notifications_none,color: Constants.primaryColor,),
            ),
          ),
        ),
        title: Container(
          width: MediaQuery.of(context).size.width *0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome Back',
                style: TextStyle(
                    color:  Colors.grey,
                    fontSize: 10
                ),
              ),
              Text(authprovider.fullname,
                style: TextStyle(
                  fontSize: 15,
                  color:  listingprovider.getForegroundColor(),
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
                borderRadius: BorderRadius.circular(40)

            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(authprovider.imageFile, fit: BoxFit.fill,),

            ),
          ),
          Container(width: 10,),
        ],
      ) :
      AppBar(
        backgroundColor: listingprovider.getBackgroundColor(),
        elevation: 0,
        title:Image.asset('assets/images/abn_logo.png'),
        actions: [
          SizedBox(
            width: 70,
            child: TextButton(
              onPressed: (){},
              child: Text('sign in',
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
              Text("Featured properties",
                style: TextStyle(
                    color: listingprovider.getForegroundColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),

              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: MediaQuery.of(context).size.width,
                height: 148,
                decoration: BoxDecoration(
                    color: listingprovider.getForegroundColor(),
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
              if(authprovider.email.isNotEmpty)
                Text("Popular near you",
                  style: TextStyle(
                      color: listingprovider.getForegroundColor(),
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),

                ),
              if(authprovider.email.isNotEmpty)
                StreamBuilder<QuerySnapshot>(
                  stream: _popularNearYouStream,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
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
                    List<QueryDocumentSnapshot<Object?>>  products= snapshot.data!.docs;


                    return Container(
                      height: 270,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:  products.length,
                          itemBuilder: (context,index){

                            String price ='';

                            List<String> ListPrice = products[index]["price"].toString().split('.');
                            String oldPrice = ListPrice[0];
                            if (oldPrice.length > 9) {
                              oldPrice = oldPrice.substring(0, oldPrice.length - 9) + "B";
                            } else if (oldPrice.length > 6){
                              oldPrice = oldPrice.substring(0, oldPrice.length - 6) + "M";

                            }else if (oldPrice.length > 3){
                              oldPrice = oldPrice.substring(0, oldPrice.length - 3)+ "K";
                            }




                            return InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewProperty(product: products[index])));

                              },
                              child: Card(
                                color: Colors.transparent.withOpacity(0),
                                shadowColor: Constants.greyColor.withOpacity(0.3),
                                elevation: 2,
                                margin: EdgeInsets.all(5),
                                child: Container(
                                  // margin: EdgeInsets.all(5),
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                      color: listingprovider.getBackgroundColor(),

                                      borderRadius: BorderRadius.circular(18)
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.maxFinite,
                                        height: 165,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(18)
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: Image(
                                            image: NetworkImage(products[index]["imageUrls"][0]),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Text(products[index]["title"].toString().length < 21 ?products[index]["title"] : products[index]["title"].toString().substring(0, 20)+"...",
                                              style: TextStyle(
                                                  color: listingprovider.getForegroundColor(),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, size: 10,),
                                            Text(products[index]["lga"] + ", ",
                                              style: TextStyle(
                                                  color: listingprovider.getForegroundColor(),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600
                                              ),
                                            ),
                                            Text(products[index]["state"] ,
                                              style: TextStyle(
                                                  color: listingprovider.getForegroundColor(),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600
                                              ),
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
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              // width: 30,x
                                              child: Center(
                                                child: Text("₦ " +oldPrice,
                                                  style: TextStyle(
                                                      color: Constants.primaryColor
                                                  ),

                                                ),
                                              ),
                                            ),
                                            Icon(Icons.favorite_border, size: 20,),


                                          ],
                                        ),
                                      ),


                                    ],
                                  ),
                                ),
                              ),
                            ) ;

                          }
                      ),
                    );


                  },
                ),
              SizedBox(height: 40,),
              Text("Recommended for you",
                style: TextStyle(
                    color: listingprovider.getForegroundColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),

              ),
              StreamBuilder<QuerySnapshot>(
                stream: _recommendedForYouStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
                  List<QueryDocumentSnapshot<Object?>>  products= snapshot.data!.docs;


                  return StaggeredGridView.countBuilder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      crossAxisCount: 2,
                      itemBuilder: (context, index) {
                        String price ='';

                        List<String> ListPrice = products[index]["price"].toString().split('.');
                        String oldPrice = ListPrice[0];
                        if (oldPrice.length > 9) {
                          oldPrice = oldPrice.substring(0, oldPrice.length - 9) + "B";
                        } else if (oldPrice.length > 6){
                          oldPrice = oldPrice.substring(0, oldPrice.length - 6) + "M";

                        }else if (oldPrice.length > 3){
                          oldPrice = oldPrice.substring(0, oldPrice.length - 3)+ "K";
                        }
                        return  InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewProperty(product: products[index])));

                          },
                          child: Card(
                            color: Colors.transparent.withOpacity(0),
                            shadowColor: Constants.greyColor.withOpacity(0.3),
                            elevation: 2,
                            margin: EdgeInsets.all(5),
                            child: Container(
                              // margin: EdgeInsets.all(5),
                              height: 260,
                              width: 200,
                              decoration: BoxDecoration(
                                  color: listingprovider.getBackgroundColor(),

                                  borderRadius: BorderRadius.circular(18)
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.maxFinite,
                                    height: 165,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18)
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image(
                                        image: NetworkImage(products[index]["imageUrls"][0]),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Text(products[index]["title"].toString().length < 15 ?products[index]["title"] : products[index]["title"].toString().substring(0, 15)+"...",
                                          style: TextStyle(
                                              color: listingprovider.getForegroundColor(),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 10,),
                                        Text(products[index]["lga"] + ", ",
                                          style: TextStyle(
                                              color: listingprovider.getForegroundColor(),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                        Text(products[index]["state"] ,
                                          style: TextStyle(
                                              color: listingprovider.getForegroundColor(),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600
                                          ),
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
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          // width: 30,x
                                          child: Center(
                                            child: Text("₦ " +oldPrice,
                                              style: TextStyle(
                                                  color: Constants.primaryColor
                                              ),

                                            ),
                                          ),
                                        ),
                                        Icon(Icons.favorite_border, size: 20,),


                                      ],
                                    ),
                                  ),


                                ],
                              ),
                            ),
                          ),
                        ) ;
                      },
                      staggeredTileBuilder: (context) => const StaggeredTile.fit(1));


                },
              )


            ],
          ),
        ),
      ),


    );
  }
}
