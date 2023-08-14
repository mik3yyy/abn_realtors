import 'dart:io';

import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_AddProperties_Screen/post_property.dart';
import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_AddProperties_Screen/view_image.dart';
import 'package:abn_realtors/provider/agent_provider/post_provider.dart';
import 'package:abn_realtors/settings/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';

import 'dart:io';

import '../../../settings/messageHandler.dart';
import '../../messages_screen/add_message_screen.dart';

class AddProperty extends StatefulWidget {
  const AddProperty({Key? key}) : super(key: key);

  @override
  State<AddProperty> createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final ImagePicker _picker = ImagePicker();
  String _imageFile = '';
  dynamic _pickedImageError;
  PageController pageController = PageController(initialPage: 0);
  bool show = false;
  int currentpage = 0;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var postprovider = Provider.of<PostProvider>(context, listen: false);

    selectedCategory = postprovider.Categories;
  }
  // final GlobalKey<ScaffoldMessengerState> _scaffoldkey =
  // GlobalKey<ScaffoldMessengerState>();

  List<String> selectedCategory = [];

  bool expanded = false;
  List<String> list = [];

  // void getSelected(BuildContext context){
  //   var postprovider = Provider.of<PostProvider>(context, listen: false);
  //
  //   List<String> list=[];
  //   for (int index = 0; index < postprovider.categories.length; index++) {
  //     if(postprovider.checks[index]){
  //       list.add(postprovider.categories[index]);
  //     }
  //
  //   }
  //   setState(() {
  //     selectedCategory = list;
  //     postprovider.Categories = list;
  //   });
  //
  //
  // }

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    var postprovider = Provider.of<PostProvider>(context, listen: true);
    void _pickImageFromCamera() async {
      try {
        final pickedImage = await _picker.pickImage(
            source: ImageSource.camera,
            maxHeight: 300,
            maxWidth: 300,
            imageQuality: 95);
        setState(() {
          _imageFile = pickedImage!.path;

          postprovider.addImage(_imageFile);
          setState(() {
            show = true;
          });
          Future.delayed(Duration(seconds: 3), () {}).then((value) {
            setState(() {
              show = false;
            });
          });
          // authprovider.imageFile = _imageFile;
        });
        // if (pickedImage!.path.isNotEmpty){
        //
        // }
      } catch (e) {
        setState(() {
          _pickedImageError = e;
        });
      }
    }

    void _pickImageFromGallery() async {
      try {
        final pickedImage = await _picker.pickMultiImage(
            maxHeight: 300, maxWidth: 300, imageQuality: 95);
        setState(() {
          for (int i = 0; i < pickedImage.length; i++) {
            _imageFile = pickedImage[i].path;
            print(postprovider.imageFiles.length);
            if (postprovider.imageFiles.length < 10) {
              postprovider.addImage(_imageFile);
            }
          }

          setState(() {
            show = true;
          });
          Future.delayed(Duration(seconds: 3), () {}).then((value) {
            setState(() {
              show = false;
            });
          });
        });
      } catch (e) {
        setState(() {
          _pickedImageError = e;
        });

        print(_pickedImageError);

        MyMessageHandler.showSnackBar(
            _scaffoldKey, "Invalid images, prefered type");
      }
    }

    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: listingprovider.getBackgroundColor(),
        body: Container(
          padding: EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 8),
          color: listingprovider.getBackgroundColor(),
          child: Scaffold(
              // key: _scaffoldKey,
              backgroundColor: listingprovider.getBackgroundColor(),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: listingprovider.getBackgroundColor(),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      if (postprovider.title.isNotEmpty &&
                          postprovider.description.isNotEmpty &&
                          postprovider.imageFiles.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostApartment()));
                      } else {
                        MyMessageHandler.showSnackBar(
                            _scaffoldKey, "Fill all field and add images");
                      }
                    },
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: 30,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Constants.primaryColor,
                          border: Border.all(color: Constants.primaryColor),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text(
                          "Add",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Constants.primaryColor,
                  ),
                ),
                title: Text(
                  "Add Property",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: listingprovider.getForegroundColor()),
                ),
              ),
              body: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    // Divider(thickness: 1,height: 4,color: Constants.primaryColor,),
                    // SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xFFEBF4FA),
                              // color:  listingprovider.lightMode? Colors.grey.withOpacity(0): listingprovider.getBackgroundColor(),

                              // border: Border.all(color: Constants.primaryColor)
                            ),
                            child: postprovider.imageFiles.isEmpty
                                ? Center(
                                    child: Text(
                                      "No Image",
                                      style: TextStyle(
                                        color: listingprovider
                                            .getForegroundColor(),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        // fontStyle: FontStyle.italic
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        show = true;
                                      });
                                      Future.delayed(
                                              Duration(seconds: 3), () {})
                                          .then((value) {
                                        setState(() {
                                          show = false;
                                        });
                                      });
                                    },
                                    onDoubleTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ImageView(
                                                    index: currentpage,
                                                  )));
                                    },
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          controller: pageController,
                                          itemCount:
                                              postprovider.imageFiles.length,
                                          onPageChanged: (int value) {
                                            setState(() {
                                              currentpage = value;
                                            });
                                            setState(() {
                                              show = true;
                                            });
                                            Future.delayed(
                                                    Duration(seconds: 3), () {})
                                                .then((value) {
                                              setState(() {
                                                show = false;
                                              });
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image: FileImage(
                                                    File(postprovider
                                                        .imageFiles[index]),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        if (show)
                                          Positioned(
                                              child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Double tap to view",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )),
                                        if (postprovider.imageFiles.length > 1)
                                          Positioned(
                                            bottom: 2,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              child: Center(
                                                child: SmoothPageIndicator(
                                                  controller: pageController,
                                                  count: postprovider
                                                      .imageFiles.length,
                                                  effect: JumpingDotEffect(
                                                    radius: 10,
                                                    activeDotColor:
                                                        Constants.primaryColor,
                                                    dotColor: Colors.white,
                                                    dotHeight: 7,
                                                    dotWidth: 7,
                                                    jumpScale: .7,
                                                    verticalOffset: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // SizedBox(height: 40,),
                              // SizedBox(height: 20,),

                              MaterialButton(
                                onPressed: () {
                                  // Navigator.pushNamed(context, LoginScreen.id);
                                  if (postprovider.imageFiles.length < 10) {
                                    _pickImageFromCamera();
                                  } else {
                                    MyMessageHandler.showSnackBar(
                                        _scaffoldKey, "Maximum of 10 pictures");
                                  }
                                },
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color:
                                          listingprovider.getBackgroundColor(),
                                      border: Border.all(
                                          color: Constants.primaryColor),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Camera ",
                                        style: TextStyle(
                                            color: Constants.primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Constants.primaryColor,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  // Navigator.pushNamed(context, SignUpScreen.id);
                                  if (postprovider.imageFiles.length < 10) {
                                    _pickImageFromGallery();
                                  } else {
                                    MyMessageHandler.showSnackBar(
                                        _scaffoldKey, "Maximum of 10 pictures");
                                  }
                                },
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Constants.primaryColor,
                                      border: Border.all(
                                          color: Constants.primaryColor),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Gallery ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Icon(
                                        Icons.photo_library,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // MaterialButton(
                              //   onPressed: (){
                              //     // Navigator.pushNamed(context, SignUpScreen.id);
                              //   },
                              //   padding: const EdgeInsets.all(4.0),
                              //   child: Container(
                              //     height: 50,
                              //     decoration:  BoxDecoration(
                              //         color: Constants.primaryColor,
                              //         border: Border.all(color: Constants.primaryColor),
                              //         borderRadius: BorderRadius.circular(8)
                              //     ),
                              //     child:  Row(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: [
                              //         Text("Clear Images ",
                              //           style: TextStyle(
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.bold
                              //           ),
                              //         ),
                              //         Icon( Icons.clear_outlined, color: Colors.white,)
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        )),
                      ],
                    ),
                    Divider(
                      color: listingprovider.lightMode
                          ? null
                          : listingprovider.getForegroundColor(),
                    ),
                    // Row(
                    //   children: [
                    //     Text('Title',
                    //       style: TextStyle(
                    //           color: listingprovider.getForegroundColor()
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 0),
                      child: TextFormField(
                          initialValue: postprovider.title,
                          maxLength: 20,
                          // controller: controller,
                          // initialValue: authprovider.password,
                          // obscureText: passwordVisible,
                          onChanged: (String value) {
                            setState(() {
                              postprovider.title = value;
                            });
                          },
                          style: TextStyle(
                            color: listingprovider.getForegroundColor(),
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'please enter your title';
                            } else {
                              return null;
                            }
                          },
                          decoration: Constants.textFormDecoration.copyWith(
                            labelText: "Title",
                            // suffixIcon: IconButton(
                            //     onPressed: () {
                            //       setState(() {
                            //         passwordVisible = !passwordVisible;
                            //       });
                            //     },
                            //     icon: Icon(
                            //       passwordVisible
                            //           ? Icons.visibility
                            //           : Icons.visibility_off,
                            //
                            //     )),
                            hintText: 'Title',

                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),

                            fillColor: Color(0xFFEBF4FA),
                            filled: true,
                          )),
                    ),
                    Divider(
                      color: listingprovider.lightMode
                          ? null
                          : listingprovider.getForegroundColor(),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(top: 5.0, bottom: 15),
                    //   child: TextFormField(
                    //       // controller: controller,
                    //       // initialValue: authprovider.password,
                    //       // obscureText: passwordVisible,
                    //       onChanged: (String? value){
                    //
                    //       },
                    //       maxLines: 10,
                    //       style: TextStyle(
                    //         color: listingprovider.getForegroundColor(),
                    //       ),
                    //       validator: (String? value ){
                    //         if (value!.isEmpty) {
                    //           return 'please enter your password';
                    //         } else {
                    //           return null;
                    //         }
                    //       },
                    //       decoration: Constants.textFormDecoration.copyWith(
                    //         prefixIcon: Icon(Icons.house),
                    //
                    //         labelText: "Title",
                    //         // suffixIcon: IconButton(
                    //         //     onPressed: () {
                    //         //       setState(() {
                    //         //         passwordVisible = !passwordVisible;
                    //         //       });
                    //         //     },
                    //         //     icon: Icon(
                    //         //       passwordVisible
                    //         //           ? Icons.visibility
                    //         //           : Icons.visibility_off,
                    //         //
                    //         //     )),
                    //         hintText: 'Title',
                    //
                    //         enabledBorder: OutlineInputBorder(
                    //           borderSide: BorderSide(color:  Constants.primaryColor,),
                    //           borderRadius: BorderRadius.circular(20),
                    //
                    //         ),
                    //       )
                    //   ),
                    // ),
                    // Row(
                    //   children: [
                    //     Text('Description',
                    //       style: TextStyle(
                    //           color: listingprovider.getForegroundColor()
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 0),
                      child: TextFormField(
                          initialValue: postprovider.description,
                          textCapitalization: TextCapitalization.sentences,
                          // controller: controller,
                          // initialValue: authprovider.password,
                          // obscureText: passwordVisible,

                          maxLength: 1000,
                          maxLines: 6,
                          onChanged: (String value) {
                            setState(() {
                              postprovider.description = value;
                            });
                          },
                          style: TextStyle(
                            color: listingprovider.getForegroundColor(),
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'please enter your Description';
                            } else {
                              return null;
                            }
                          },
                          decoration: Constants.textFormDecoration.copyWith(
                            hintText: 'Description',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            fillColor: Color(0xFFEBF4FA),
                            filled: true,
                          )),
                    ),
                    Divider(
                      color: listingprovider.lightMode
                          ? null
                          : listingprovider.getForegroundColor(),
                    ),

                    ExpansionTile(
                      // collapsedBackgroundColor: Color(0xFFEBF4FA),

                      title: Text(
                        "Category",
                        style: TextStyle(
                            color: listingprovider.getForegroundColor()),
                      ),
                      tilePadding: EdgeInsets.only(left: 10, right: 10),
                      iconColor: Constants.greyColor,
                      // collapsedIconColor: Constants.greyColor,
                      trailing: Icon(
                        Icons.arrow_drop_down,
                        color: listingprovider.lightMode
                            ? Colors.black
                            : Colors.grey.withOpacity(0.7),
                      ),
                      subtitle: expanded
                          ? Text(
                              "Select only One",
                              style: TextStyle(
                                  color: listingprovider.getForegroundColor()),
                            )
                          : Container(
                              padding: EdgeInsets.only(top: 10),
                              height: expanded
                                  ? 60
                                  : selectedCategory.length < 4 &&
                                          selectedCategory.isNotEmpty
                                      ? 60
                                      : selectedCategory.isEmpty
                                          ? 0
                                          : 120,
                              child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 110,
                                          childAspectRatio: 2,
                                          crossAxisSpacing: 2,
                                          mainAxisSpacing: 3),
                                  itemCount: selectedCategory.length,
                                  itemBuilder: (BuildContext ctx, index) {
                                    return Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          // color:listingprovider.lightMode? Constants.greyColor.withOpacity(0.7): Color(0xFF303134) ,
                                          color: Color(0xFFEBF4FA),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(
                                        selectedCategory[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: listingprovider
                                                .getForegroundColor()),
                                      ),
                                    );
                                  }),
                            ),
                      onExpansionChanged: (value) {
                        setState(() {
                          expanded = value;
                        });
                      },

                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: PhysicalModel(
                                  // : EdgeInsets.all(10),

                                  elevation: 8,
                                  shadowColor: listingprovider.lightMode
                                      ? Color(0xFF000000)
                                      : Color(0xFF303134),
                                  color: listingprovider.lightMode
                                      ? Colors.white
                                      : Color(0xFF303134),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListView.builder(
                                        itemCount:
                                            postprovider.categories.length ~/ 2,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              Checkbox(
                                                  side: BorderSide(
                                                      color: listingprovider
                                                          .getForegroundColor()),
                                                  value: postprovider
                                                      .checks[index],
                                                  onChanged: (value) {
                                                    int current = index;
                                                    setState(() {
                                                      for (int index = 0;
                                                          index <
                                                              postprovider
                                                                  .categories
                                                                  .length;
                                                          index++) {
                                                        if (index != current) {
                                                          postprovider.checks[
                                                              index] = false;
                                                        } else if (index ==
                                                            current) {
                                                          postprovider.checks[
                                                                  index] =
                                                              !postprovider
                                                                      .checks[
                                                                  index];
                                                        }
                                                        if (postprovider
                                                            .checks[index]) {
                                                          list.clear();

                                                          list.add(postprovider
                                                                  .categories[
                                                              index]);
                                                        }
                                                      }
                                                      selectedCategory = list;
                                                      postprovider.Categories =
                                                          list;

                                                      print(postprovider
                                                          .Categories);
                                                    });
                                                  }),
                                              Text(
                                                postprovider.categories[index],
                                                style: TextStyle(
                                                    color: listingprovider
                                                        .getForegroundColor()),
                                              )
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              Expanded(
                                child: PhysicalModel(
                                  elevation: 8,
                                  shadowColor: listingprovider.lightMode
                                      ? Color(0xFF000000)
                                      : Color(0xFF303134),
                                  color: listingprovider.lightMode
                                      ? Colors.white
                                      : Color(0xFF303134),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      // color:  Colors.white,
                                    ),
                                    child: ListView.builder(
                                        itemCount:
                                            postprovider.categories.length,
                                        itemBuilder: (context, index) {
                                          if (index <
                                              postprovider.categories.length ~/
                                                  2) {
                                            return Container();
                                          }
                                          return Row(
                                            children: [
                                              Checkbox(
                                                  side: BorderSide(
                                                      color: listingprovider
                                                          .getForegroundColor()),
                                                  value: postprovider
                                                      .checks[index],
                                                  onChanged: (value) {
                                                    int current = index;
                                                    setState(() {
                                                      for (int index = 0;
                                                          index <
                                                              postprovider
                                                                  .categories
                                                                  .length;
                                                          index++) {
                                                        if (index != current) {
                                                          postprovider.checks[
                                                              index] = false;
                                                        } else if (index ==
                                                            current) {
                                                          postprovider.checks[
                                                                  index] =
                                                              !postprovider
                                                                      .checks[
                                                                  index];
                                                        }
                                                        if (postprovider
                                                            .checks[index]) {
                                                          list.clear();
                                                          list.add(postprovider
                                                                  .categories[
                                                              index]);
                                                        }
                                                      }

                                                      selectedCategory = list;
                                                      postprovider.Categories =
                                                          list;

                                                      print(postprovider
                                                          .Categories);
                                                    });
                                                  }),
                                              Text(
                                                postprovider.categories[index],
                                                style: TextStyle(
                                                    color: listingprovider
                                                        .getForegroundColor()),
                                              )
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
