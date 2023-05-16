

import 'dart:io';

import 'package:abn_realtors/main_screens/Agents_main_screens/agents_main_screen.dart';
import 'package:abn_realtors/settings/messageHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


import '../../../provider/agent_provider/post_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';
import '../../../settings/constants.dart';
import 'package:path/path.dart' as path;

class PostApartment extends StatefulWidget {
  const PostApartment({Key? key}) : super(key: key);

  @override
  State<PostApartment> createState() => _PostApartmentState();
}

class _PostApartmentState extends State<PostApartment> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldkey =
  GlobalKey<ScaffoldMessengerState>();

  CollectionReference properties =
  FirebaseFirestore.instance.collection('properties');

  String selectedState = "Lagos";
  final TextEditingController StateEditingController = TextEditingController();
  String? selectedLGA ;
  final TextEditingController textEditingController = TextEditingController();




  // bool checked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var postprovider = Provider.of<PostProvider>(context, listen: false);

    selectedState = postprovider.state.isNotEmpty ? postprovider.state: "Lagos";
    postprovider.state = postprovider.state.isNotEmpty?postprovider.state: "Lagos";
    selectedLGA = postprovider.lga.isNotEmpty ? postprovider.lga : null;


  }
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    var postprovider = Provider.of<PostProvider>(context, listen: true);
    List<String>? state = Constants.statesMap[selectedState]!.toList();

    void post() async{


      var checkMessage = postprovider.checkData();

      if( checkMessage.isEmpty){


          setState(() {
            processing = true;
          });
          postprovider.pid = Uuid().v4();
          postprovider.uid = FirebaseAuth.instance.currentUser!.uid;



          try {
            int index =0;
            for (var image in postprovider.imageFiles) {
              index ++;
              firebase_storage.Reference ref = firebase_storage
                  .FirebaseStorage.instance
                  .ref('products/${postprovider.pid} - ${index} ');

              await ref.putFile(File(image)).whenComplete(() async {
                await ref.getDownloadURL().then((value) {
                  postprovider.imageUrls.add(value);
                });
              });
            }
            await properties.doc(postprovider.pid).set(postprovider.getProperty());

            setState(() {
              processing = false ;

            });
            MyMessageHandler.showSnackBar(_scaffoldkey, "successful uploaded");


            Future.delayed(Duration(seconds: 1) ,(){

              postprovider.clear();}
            ).then((value) {
              Navigator.of(context).pushNamedAndRemoveUntil(AgentMainScreen.id,(Route route) => route == null);
            });



          } catch (e) {
            MyMessageHandler.showSnackBar(_scaffoldkey, "error uploading, check your network and try again ");
            setState(() {
              processing = false ;

            });


            print(e);
          }








      } else {
        setState(() {
          processing = false;
        });
        MyMessageHandler.showSnackBar(_scaffoldkey,  checkMessage);
      }





    }

    return ScaffoldMessenger(
      key: _scaffoldkey,
      child: Scaffold(
        backgroundColor: listingprovider.getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: listingprovider.getBackgroundColor(),
          elevation: 0,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.chevron_left, size: 30, color: listingprovider.getForegroundColor(),),

          ),
          actions: [
          processing? Container():

          TextButton(onPressed: (){post();}, child:Text("Post") )
          ],
        ),
        body:processing? Center(child: Container(
          margin: EdgeInsets.only(right: 10),
          child: LoadingAnimationWidget.hexagonDots(
            color: Constants.primaryColor,
            // rightDotColor: Constant.generalColor,
            size: 40,
          ),
        ),)
            :
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Add Location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: Constants.statesMap.keys
                          .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style:  TextStyle(
                            fontSize: 14,
                            color: listingprovider.getForegroundColor()
                          ),
                        ),
                      ))
                          .toList(),
                      value: selectedState,
                      style: TextStyle(
                        color: listingprovider.getForegroundColor()
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedLGA = null;
                          postprovider.lga ="";
                          selectedState = value as String;
                          postprovider.state = value;
                        });
                      },
                      buttonStyleData:  ButtonStyleData(
                        height: 40,
                        width: 200,

                      ),
                      dropdownStyleData:  DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                          color: listingprovider.lightMode? listingprovider.getBackgroundColor(): Colors.black
                        )
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                      dropdownSearchData: DropdownSearchData(
                        searchController: textEditingController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: textEditingController,
                            style: TextStyle(
                              color: listingprovider.getForegroundColor()
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: 'Search for an item...',
                              hintStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: listingprovider.getForegroundColor())

                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return (item.value.toString().contains(searchValue));
                        },
                      ),
                      //This to clear the search value when you close the menu
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          textEditingController.clear();
                        }
                      },
                    ),
                  ),
                ),
                Divider(color: listingprovider.lightMode? null : listingprovider.getForegroundColor(), thickness: 2,),
                Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Add location',
                        style: TextStyle(

                          fontSize: 14,
                          color: listingprovider.getForegroundColor(),
                        ),
                      ),
                      style: TextStyle(
                          color: listingprovider.getForegroundColor()
                      ),
                      items: state.map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          textAlign: TextAlign.center,
                          style:  TextStyle(
                            color: listingprovider.getForegroundColor(),
                            fontSize: 14,
                          ),
                        ),
                      ))
                          .toList(),
                      value: selectedLGA,
                      onChanged: ( value) {
                        setState(() {
                          selectedLGA = value as String;
                          postprovider.lga = value;

                        });
                      },


                      buttonStyleData:  ButtonStyleData(
                        padding: EdgeInsets.only(left: 0),
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                      ),
                      dropdownStyleData:  DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                          color: listingprovider.lightMode? null : Colors.black
                        )
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                      dropdownSearchData: DropdownSearchData(
                        searchController: textEditingController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: textEditingController,
                            style: TextStyle(
                              color: listingprovider.getForegroundColor()
                            ),
                            decoration: InputDecoration(

                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: 'Search for an item...',
                              hintStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return (item.value.toString().contains(searchValue));
                        },
                      ),
                      //This to clear the search value when you close the menu
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          textEditingController.clear();
                        }
                      },
                    ),
                  ),
                ),
                Divider(color: listingprovider.lightMode? null : listingprovider.getForegroundColor(), thickness: 2,),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Price(₦)",
                        style: TextStyle(
                          color: listingprovider.getForegroundColor()
                        ),

                      ),
                      Container(
                        width: MediaQuery.of(context).size.width*0.5,
                        height: 50,
                        child: TextFormField(
                          initialValue: postprovider.price,
                            validator: (String? value){
                              if (value!.isEmpty){
                                return 'what is your price';
                              }
                              return null;
                            },
                            onChanged: (String  value){
                              try{

                                  postprovider.price =value;

                              } catch(e){
                                if(value.isNotEmpty){
                                  MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                }

                              }



                            },
                            maxLength: 13,
                            style: TextStyle(
                                color: listingprovider.getForegroundColor()
                            ),

                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: Constants.textFormDecoration.copyWith(
                              hintText: "5000.00",
                              hintStyle: TextStyle(
                                  color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                              ),
                              counterStyle: TextStyle(height: double.minPositive,),
                              counterText: "",



                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                borderRadius: BorderRadius.circular(10),

                              ),


                            )
                        ),
                      ),


                    ],
                  ),
                ),
                Divider(color: listingprovider.lightMode? null : listingprovider.getForegroundColor(), thickness: 2,),
                //RAW LAND
                if(postprovider.Categories.first == "Raw land")
                   Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Area (sqm)",
                            style: TextStyle(
                                color: listingprovider.getForegroundColor()
                            ),

                          ),

                          Container(

                            width: MediaQuery.of(context).size.width*0.25,
                            height: 50,
                            child: TextFormField(
                                initialValue: postprovider.length,

                                onChanged: (String  value){
                                  try{

                                    postprovider.length =value;

                                  } catch(e){
                                    if(value.isNotEmpty){
                                      MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                    }

                                  }

                                },
                                maxLength: 7,
                                style: TextStyle(
                                    color: listingprovider.getForegroundColor()
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                decoration: Constants.textFormDecoration.copyWith(
                                  hintText: "30(m)",
                                  hintStyle: TextStyle(
                                      color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                                  ),
                                  counterStyle: TextStyle(height: double.minPositive,),
                                  counterText: "",



                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                    borderRadius: BorderRadius.circular(10),

                                  ),


                                )
                            ),
                          ),
                          Text("X",
                              style: TextStyle(
                                  color: listingprovider.getForegroundColor()
                              )
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            height: 50,
                            child: TextFormField(
                                initialValue: postprovider.breath,

                                onChanged: (String  value){
                                  try{

                                    postprovider.breath =value;

                                  } catch(e){
                                    if(value.isNotEmpty){
                                      MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                    }

                                  }

                                },
                                style: TextStyle(
                                    color: listingprovider.getForegroundColor()
                                ),
                                maxLength: 7,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                decoration: Constants.textFormDecoration.copyWith(
                                  hintText: "30(m)",
                                  hintStyle: TextStyle(
                                      color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                                  ),

                                  counterStyle: TextStyle(height: double.minPositive,),
                                  counterText: "",

                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                    borderRadius: BorderRadius.circular(10),

                                  ),


                                )
                            ),
                          ),


                        ],
                      ),
                    ),
                    Divider(color: listingprovider.lightMode? null : listingprovider.getForegroundColor(), thickness: 2,),
                  ],
                ),
                if(postprovider.Categories.first == "Terrace" ||postprovider.Categories.first == "Semi-detached" ||postprovider.Categories.first == "Building" ||postprovider.Categories.first == "Apartment"  ||postprovider.Categories.first == "Mansion"  ||postprovider.Categories.first == "Penthouse"   )
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("Bedroom ",
                                  style: TextStyle(
                                      color: listingprovider.getForegroundColor()
                                  ),

                                ),
                                Container(
                                  width:50,
                                  height: 50,
                                  child: TextFormField(
                                      initialValue: postprovider.bedroom,
                                      validator: (String? value){
                                        if (value!.isEmpty){
                                          return 'what is your bedroom';
                                        }
                                        return null;
                                      },
                                      onChanged: (String  value){
                                        try{

                                          postprovider.bedroom = value;

                                        } catch(e){
                                          if(value.isNotEmpty){
                                            MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                          }

                                        }

                                      },
                                      maxLength: 2,
                                      style: TextStyle(
                                          color: listingprovider.getForegroundColor()
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(),
                                      decoration: Constants.textFormDecoration.copyWith(
                                        hintText: "4",
                                        counterStyle: TextStyle(height: double.minPositive,),
                                        counterText: "",
                                        hintStyle: TextStyle(
                                            color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                                        ),


                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                          borderRadius: BorderRadius.circular(10),

                                        ),


                                      )
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Toilet ",
                                  style: TextStyle(
                                      color: listingprovider.getForegroundColor()
                                  ),

                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  child: TextFormField(
                                      initialValue: postprovider.toilet,
                                      onChanged: (String  value){

                                        try{

                                          postprovider.toilet = value;

                                        } catch(e){
                                          if(value.isNotEmpty){
                                            MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                          }

                                        }



                                      },
                                      maxLength: 2,
                                      style: TextStyle(
                                          color: listingprovider.getForegroundColor()
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(),
                                      decoration: Constants.textFormDecoration.copyWith(
                                        hintText: "4",
                                        hintStyle: TextStyle(
                                            color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                                        ),
                                        counterStyle: TextStyle(height: double.minPositive,),
                                        counterText: "",




                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                          borderRadius: BorderRadius.circular(10),

                                        ),


                                      )
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Floors ",
                                  style: TextStyle(
                                      color: listingprovider.getForegroundColor()
                                  ),

                                ),
                                Container(
                                  width: 50,
                                  height: 50,

                                  child: TextFormField(
                                      initialValue: postprovider.toilet,
                                      validator: (String? value){
                                        if (value!.isEmpty){
                                          return 'what is your price';
                                        }
                                        return null;
                                      },
                                      onChanged: (String  value){
                                        try{

                                          postprovider.floors =value;

                                        } catch(e){
                                          if(value.isNotEmpty){
                                            MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                          }

                                        }


                                      },
                                      style: TextStyle(
                                          color: listingprovider.getForegroundColor()
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(),
                                      maxLength: 2,


                                      decoration: Constants.textFormDecoration.copyWith(
                                        hintText: "4",
                                        hintStyle: TextStyle(
                                            color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                                        ),

                                        counterStyle: TextStyle(height: double.minPositive,),
                                        counterText: "",




                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                          borderRadius: BorderRadius.circular(10),

                                        ),


                                      )
                                  ),
                                ),
                              ],
                            ),







                          ],
                        ),
                      ),
                      Divider(color: listingprovider.lightMode? null : listingprovider.getForegroundColor(), thickness: 2,),
                    ],
                  ),

                if (postprovider.Categories.first == "Office Space")
                  Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text("Rooms ",
                                style: TextStyle(
                                    color: listingprovider.getForegroundColor()
                                ),

                              ),
                              Container(
                                width:50,
                                height: 50,
                                child: TextFormField(
                                    initialValue: postprovider.rooms,

                                    onChanged: (String  value){
                                      try{

                                        postprovider.rooms = value;

                                      } catch(e){
                                        if(value.isNotEmpty){
                                          MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                        }

                                      }

                                    },
                                    maxLength: 2,
                                    style: TextStyle(
                                        color: listingprovider.getForegroundColor()
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(),
                                    decoration: Constants.textFormDecoration.copyWith(
                                      hintText: "4",
                                      counterStyle: TextStyle(height: double.minPositive,),
                                      counterText: "",
                                      hintStyle: TextStyle(
                                          color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                                      ),

                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                        borderRadius: BorderRadius.circular(10),

                                      ),


                                    )
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Toilet ",
                                style: TextStyle(
                                    color: listingprovider.getForegroundColor()
                                ),

                              ),
                              Container(
                                width: 50,
                                height: 50,
                                child: TextFormField(
                                    initialValue: postprovider.toilet,
                                    onChanged: (String  value){

                                      try{

                                        postprovider.toilet = value;

                                      } catch(e){
                                        if(value.isNotEmpty){
                                          MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                        }

                                      }



                                    },
                                    maxLength: 2,
                                    style: TextStyle(
                                        color: listingprovider.getForegroundColor()
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(),
                                    decoration: Constants.textFormDecoration.copyWith(
                                      hintText: "4",
                                      hintStyle: TextStyle(
                                          color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                                      ),
                                      counterStyle: TextStyle(height: double.minPositive,),
                                      counterText: "",




                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                        borderRadius: BorderRadius.circular(10),

                                      ),


                                    )
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Floors ",
                                style: TextStyle(
                                    color: listingprovider.getForegroundColor()
                                ),

                              ),
                              Container(
                                width: 50,
                                height: 50,

                                child: TextFormField(
                                    initialValue: postprovider.toilet,

                                    onChanged: (String  value){
                                      try{

                                        postprovider.floors =value;

                                      } catch(e){
                                        if(value.isNotEmpty){
                                          MyMessageHandler.showSnackBar(_scaffoldkey, "Input a number");
                                        }

                                      }


                                    },
                                    style: TextStyle(
                                        color: listingprovider.getForegroundColor()
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(),
                                    maxLength: 2,


                                    decoration: Constants.textFormDecoration.copyWith(
                                      hintText: "4",
                                      hintStyle: TextStyle(
                                          color:listingprovider.lightMode?Colors.black38: Color(0xFF303134)
                                      ),

                                      counterStyle: TextStyle(height: double.minPositive,),
                                      counterText: "",




                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                        borderRadius: BorderRadius.circular(10),

                                      ),


                                    )
                                ),
                              ),
                            ],
                          ),







                        ],
                      ),
                    ),
                    Divider(color: listingprovider.lightMode? null : listingprovider.getForegroundColor(), thickness: 2,),
                  ],
                ),








              ],
            ),
          ),
        ),
      ),
    );

  }
}

extension QuantityValidator on String {
  bool isValidQuantity() {
    return RegExp(r'^[1-9][0-9]*$').hasMatch(this);
  }
}

extension PriceValidator on String {
  bool isValidPrice() {
    return RegExp(r'^((([1-9][0-9]*[\.]*)||([0][\.]*))([0-9]{1,2}))$')
        .hasMatch(this);
  }
}
