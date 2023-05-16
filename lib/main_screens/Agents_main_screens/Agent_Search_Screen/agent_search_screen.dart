import 'package:abn_realtors/utils/GridDummyScreen.dart';
import 'package:abn_realtors/utils/ListDummyScreen.dart';
import 'package:abn_realtors/utils/dummy_screen.dart';
import 'package:abn_realtors/utils/empty_screen.dart';
import 'package:abn_realtors/utils/property_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../provider/agent_provider/post_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';
import '../../../settings/constants.dart';
import '../Agent_Home_Screen/view_property.dart';

class AgentSearchScreen extends StatefulWidget {
  const AgentSearchScreen({Key? key}) : super(key: key);

  @override
  State<AgentSearchScreen> createState() => _AgentSearchScreenState();
}

class _AgentSearchScreenState extends State<AgentSearchScreen> {

  int currentinddex =0;
  final TextEditingController SearchController = TextEditingController();

  String search = '';
  bool online = true;

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    var postprovider = Provider.of<PostProvider>(context, listen: true);

     Stream<QuerySnapshot> _categoryProductStream = FirebaseFirestore.instance
        .collection('properties')
        .where( 'Category' , isEqualTo: postprovider.categories[currentinddex])
        .snapshots();
     Stream<QuerySnapshot> _searchProductStream = FirebaseFirestore.instance
        .collection('properties')
        .snapshots();

     Stream<QuerySnapshot> _promoProductStream = FirebaseFirestore.instance
        .collection('properties')
        .snapshots();

    return LiquidPullToRefresh(
      onRefresh: () async {
        online= await InternetConnectionChecker().hasConnection;

        setState(() {
         _categoryProductStream = FirebaseFirestore.instance
              .collection('properties')
              .where( 'Categories' , arrayContains: postprovider.categories[currentinddex])
              .snapshots();
           _searchProductStream = FirebaseFirestore.instance
              .collection('properties')
              .snapshots();

         _promoProductStream = FirebaseFirestore.instance
              .collection('properties')
              .snapshots();
        });

      },
      color:listingprovider.lightMode?Colors.white: Colors.black,
      backgroundColor: listingprovider.lightMode?Colors.black: Colors.white,
      child: ConnectivityWidget(

          showOfflineBanner: false,
          builder: (context, isOnline){
            WidgetsBinding.instance.addPostFrameCallback((_){

              // Add Your Code here.
              if(online!= isOnline && isOnline == true){
                setState(() {
                  online = isOnline;

                });



              } else if (online!= isOnline && isOnline == false){
                setState(() {
                  online = isOnline;

                });


              }

            });

            return isOnline? Scaffold(
              backgroundColor: listingprovider.getBackgroundColor(),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: listingprovider.getBackgroundColor(),
                title: Text("Search",
                  style:TextStyle(
                    color: listingprovider.getForegroundColor(),
                  ),

                ),
                bottom: PreferredSize(preferredSize: Size.fromHeight(70),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5,bottom: 15, right: 10, left: 10),
                    child: TextFormField(
                        controller: SearchController,

                        onChanged: (String  value){
                          setState(() {
                            search = value;

                          });
                        },
                        validator: (String? value){
                          if (value!.isEmpty){
                            return 'enter your full name';
                          } else {
                            return null;
                          }
                        },
                        style: TextStyle(
                            color: listingprovider.getForegroundColor()
                        ),
                        decoration: Constants.textFormDecoration.copyWith(
                          suffixIcon: Icon(Icons.search),

                          hintText: 'Search a house',
                          enabledBorder: OutlineInputBorder(



                            borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                            borderRadius: BorderRadius.circular(10),

                          ),
                        )
                    ),
                  ),

                ),
              ),
              body: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      height: 50,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: postprovider.categories.length,
                          itemBuilder: (context, index){
                            return GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentinddex = index;
                                  search ='';
                                  SearchController.text ='';
                                });
                              },
                              child: Container(

                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Constants.primaryColor),
                                    borderRadius: BorderRadius.circular(10),
                                    color:  currentinddex == index ? Constants.primaryColor : listingprovider.lightMode? Constants.lightColor: listingprovider.getBackgroundColor()
                                ),
                                child: Center(
                                  child: Text(postprovider.categories[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:  currentinddex == index ? Constants.lightColor : Color(0xFFB0B0B0)
                                    ),


                                  ),
                                ),

                              ),
                            );
                          }
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Top Results",
                        style: TextStyle(
                            color: listingprovider.getForegroundColor(),
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),

                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: search.isNotEmpty? _searchProductStream:  _categoryProductStream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return ListDummyScreen();
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return ListDummyScreen();
                        }

                        if (snapshot.data!.docs.isEmpty) {


                          return const Center(
                              child: Text(
                                'No Result',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5),
                              ));
                        }
                        List<QueryDocumentSnapshot<Object?>>  products= snapshot.data!.docs;
                        Iterable<QueryDocumentSnapshot<Object?>>?  result = snapshot.data!.docs;
                        int length = snapshot.data!.docs.length;
                        int index =0;



                        if(search.isNotEmpty){

                          result = snapshot.data!.docs.where(
                                (e) => e['title'.toLowerCase()]
                                .contains(search.toLowerCase()),
                          );
                          if (result.isEmpty){
                            result = snapshot.data!.docs.where(
                                  (e) => e['state'].toString().toLowerCase()
                                  .contains(search.toLowerCase()),
                            );

                          }

                        }

                        return Container(
                          height: 270,
                          child: search.isNotEmpty?
                          ListView(
                            scrollDirection: Axis.horizontal,
                            children: result.map((product) {



                              List<String> ListPrice = product["price"].toString().split('.');
                              String oldPrice = ListPrice[0];
                              if (oldPrice.length > 9) {
                                oldPrice = oldPrice.substring(0, oldPrice.length - 9) + "B";
                              } else if (oldPrice.length > 6){
                                oldPrice = oldPrice.substring(0, oldPrice.length - 6) + "M";

                              }else if (oldPrice.length > 3){
                                oldPrice = oldPrice.substring(0, oldPrice.length - 3)+ "K";
                              }

                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewProperty(product: product)));

                                },
                                child: PropertyCard(product: product,index: index++,),
                              );
                            }).toList(),

                          ):

                          ListView.builder(
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
                                  child: PropertyCard(product: products[index],index: index,)
                                ) ;

                              }
                          ),
                        );


                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("More like this",
                        style: TextStyle(
                            color: listingprovider.getForegroundColor(),
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),

                      ),
                    ),

                    StreamBuilder<QuerySnapshot>(
                      stream: _promoProductStream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return GridDummyScreen();
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return GridDummyScreen();
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return EmptyScreen();
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
                                child:  PropertyCard(product: products[index],index: index,),
                              ) ;
                            },
                            staggeredTileBuilder: (context) => const StaggeredTile.fit(1));


                      },
                    )



                  ],
                ),
              ),
            ):
            Scaffold(body: DummyScreen());
          }
          ),
    );

  }
}
