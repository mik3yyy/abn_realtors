import 'package:abn_realtors/settings/messageHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';
import '../../../utils/bottom_sheet.dart';
import '../../../settings/constants.dart';

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AgentEditProfile extends StatefulWidget {
  const AgentEditProfile({Key? key}) : super(key: key);

  @override
  State<AgentEditProfile> createState() => _AgentEditProfileState();
}

class _AgentEditProfileState extends State<AgentEditProfile> {
  final ImagePicker _picker = ImagePicker();
  String _imageFile = '';
  dynamic _pickedImageError;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final abnBox = Hive.box('abn');
// local var
  String fullname = '';
  String phonenumber = '';
  String state = '';
  String lga = '';
  String selectedCode = '+234';
  String selectedGender = 'Male';
  bool networkimage = false;
  bool isVerified = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageFile = Provider.of<AuthProvider>(context, listen: false).imageFile;
    networkimage = _imageFile.isNotEmpty ? true : false;
    selectedGender = Provider.of<AuthProvider>(context, listen: false).gender;

    /////////////////////////////
    var authprovider = Provider.of<AuthProvider>(context, listen: false);

    fullname = authprovider.fullname;
    phonenumber = authprovider.phonenumber;
    state = authprovider.location;
    lga = authprovider.lga;
  }

  //firebase
  String _uid = '';
  CollectionReference customers =
      FirebaseFirestore.instance.collection('agents');
  final List<String> items = Constants.countriesCode.values.toList();
  final List<String> genders = [
    'Male',
    'Female',
    'Others',
  ];
  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    List<DropdownMenuItem<String>> _menuItems = [];
    for (var item in items) {
      _menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return _menuItems;
  }

  List<double> _getCustomItemsHeights() {
    List<double> _itemsHeights = [];
    for (var i = 0; i < (items.length * 2) - 1; i++) {
      if (i.isEven) {
        _itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        _itemsHeights.add(4);
      }
    }
    return _itemsHeights;
  }

  List<double> _getCustomGenderHeights() {
    List<double> _itemsHeights = [];
    for (var i = 0; i < (genders.length * 2) - 1; i++) {
      if (i.isEven) {
        _itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        _itemsHeights.add(4);
      }
    }
    return _itemsHeights;
  }

  bool processing = false;

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    void _pickImageFromCamera() async {
      try {
        final pickedImage = await _picker.pickImage(
            source: ImageSource.camera,
            maxHeight: 300,
            maxWidth: 300,
            imageQuality: 95);
        setState(() {
          _imageFile = pickedImage!.path;
          networkimage = false;
        });
        // if (pickedImage!.path.isNotEmpty){
        //
        // }
      } catch (e) {
        setState(() {
          _pickedImageError = e;
        });
        print(_pickedImageError);
      }
    }

    void _pickImageFromGallery() async {
      try {
        final pickedImage = await _picker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 300,
            maxWidth: 300,
            imageQuality: 95);
        if (pickedImage!.path != null) {
          setState(() {
            _imageFile = pickedImage.path;
            networkimage = false;
          });
        }
      } catch (e) {
        setState(() {
          _pickedImageError = e;
        });
        print(_pickedImageError);
      }
    }

    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: listingprovider.getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: listingprovider.getBackgroundColor(),
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left,
              size: 40,
              color: listingprovider.getForegroundColor(),
            ),
          ),
          title: Text(
            "Edit  Agent Profile",
            style: TextStyle(color: listingprovider.getForegroundColor()),
          ),
        ),
        body: Scaffold(
          backgroundColor: listingprovider.getBackgroundColor(),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      networkimage
                          ? Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    authprovider.imageFile,
                                    fit: BoxFit.fill,
                                  )),
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade400,
                              backgroundImage: _imageFile.isEmpty
                                  ? null
                                  : FileImage(File(_imageFile)),
                              child: _imageFile.isEmpty
                                  ? Icon(Icons.person,
                                      size: 60,
                                      color:
                                          listingprovider.getBackgroundColor())
                                  : Container(),
                            ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Constants.primaryColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15))),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _pickImageFromCamera();
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Constants.primaryColor,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15))),
                            child: IconButton(
                              icon: const Icon(
                                Icons.photo,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _pickImageFromGallery();
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full name',
                          style: TextStyle(
                              color: listingprovider.getForegroundColor()),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 15),
                          child: TextFormField(
                              initialValue: authprovider.fullname,
                              onChanged: (String? value) {
                                fullname = value!;
                              },
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'enter your full name';
                                } else {
                                  return null;
                                }
                              },
                              style: TextStyle(
                                  color: listingprovider.getForegroundColor()),
                              decoration: Constants.textFormDecoration.copyWith(
                                  hintText: 'Okpechi Michael',
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )
                                  // enabledBorder: OutlineInputBorder(
                                  //
                                  //     borderSide: BorderSide(color:  listingprovider.getForegroundColor(),)
                                  // ),
                                  )),
                        ),
                        Text(
                          'Phone number',
                          style: TextStyle(
                              color: listingprovider.getForegroundColor()),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 15),
                          child: TextFormField(
                              initialValue: authprovider.phonenumber,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'enter your phone number';
                                } else if (value.length < 10) {
                                  return 'invalid phone number ';
                                } else if (value.contains('+234') == false) {
                                  return 'invalid phone number ';
                                } else {
                                  return null;
                                }
                              },
                              style: TextStyle(
                                  color: listingprovider.getForegroundColor()),
                              onChanged: (String? value) {
                                phonenumber = value!;
                              },
                              decoration: Constants.textFormDecoration.copyWith(
                                prefixIconColor:
                                    listingprovider.getForegroundColor(),
                                hintText: 'Phone number',
                              )),
                        ),
                        Text(
                          'Gender',
                          style: TextStyle(
                              color: listingprovider.getForegroundColor()),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 15),
                          child: TextFormField(
                              decoration: Constants.textFormDecoration.copyWith(
                            prefixIcon: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                hint: Text(
                                  'Select Item',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                alignment: AlignmentDirectional.center,
                                style: TextStyle(
                                    color:
                                        listingprovider.getForegroundColor()),
                                items: genders
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: listingprovider
                                                    .getForegroundColor()),
                                          ),
                                        ))
                                    .toList(),
                                value: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value as String;
                                    print(authprovider.gender);
                                  });
                                },
                                dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                  color: listingprovider.lightMode
                                      ? Colors.white
                                      : Colors.black,
                                )),
                                buttonStyleData: ButtonStyleData(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                ),
                              ),
                            ),
                            hintText: 'Select Gender',
                            // enabledBorder: OutlineInputBorder(
                            //
                            //     borderSide: BorderSide(color:  listingprovider.getForegroundColor(),)
                            // ),
                          )),
                        ),
                        Text(
                          'State',
                          style: TextStyle(
                              color: listingprovider.getForegroundColor()),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 15),
                          child: TextFormField(
                              initialValue: authprovider.location,
                              onChanged: (String? value) {
                                state = value!;
                              },
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'enter your State';
                                } else {
                                  return null;
                                }
                              },
                              style: TextStyle(
                                  color: listingprovider.getForegroundColor()),
                              decoration: Constants.textFormDecoration.copyWith(
                                hintText: 'State',
                                // enabledBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color:  listingprovider.getForegroundColor(),)
                                // ),
                              )),
                        ),
                        Text(
                          'LGA',
                          style: TextStyle(
                              color: listingprovider.getForegroundColor()),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 15),
                          child: TextFormField(
                              initialValue: authprovider.lga,
                              onChanged: (String? value) {
                                lga = value!;
                              },
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'enter your local government area';
                                } else {
                                  return null;
                                }
                              },
                              style: TextStyle(
                                  color: listingprovider.getForegroundColor()),
                              decoration: Constants.textFormDecoration.copyWith(
                                hintText: 'Local Government Area',
                                // enabledBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color:  listingprovider.getForegroundColor(),)
                                // ),
                              )),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              print(_imageFile);
                              print(fullname);
                              print(selectedGender);
                              print(phonenumber);
                              print(state);
                              print(lga);

                              if (authprovider.imageFile == _imageFile &&
                                  authprovider.fullname == fullname &&
                                  authprovider.gender == selectedGender &&
                                  authprovider.phonenumber == phonenumber &&
                                  authprovider.location == state &&
                                  authprovider.lga == lga) {
                                print("2");
                                MyMessageHandler.showSnackBar(
                                    _scaffoldKey, "Done!");
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor:
                                      Colors.black38.withOpacity(0),
                                  builder: (context) => CustomBottomSheet(
                                    title: 'Edit Profile',
                                    description:
                                        'Are you sure you want to save this?',
                                    tapNoText: 'Cancel',
                                    tapYesText: 'Save',
                                    noTap: () {
                                      Navigator.pop(context);
                                    },
                                    yesTap: () async {
                                      setState(() {
                                        listingprovider
                                            .bottomSheetYesProcessing = true;
                                      });
                                      try {
                                        if (networkimage == false) {
                                          firebase_storage.Reference ref =
                                              firebase_storage
                                                  .FirebaseStorage.instance
                                                  .ref(
                                                      'agent-images/${authprovider.email}.jpg');

                                          await ref.putFile(File(_imageFile));

                                          _imageFile =
                                              await ref.getDownloadURL();

                                          authprovider.imageFile = _imageFile;
                                        }

                                        _uid = FirebaseAuth
                                            .instance.currentUser!.uid;

                                        print(lga);

                                        await customers.doc(_uid).set({
                                          'email': authprovider.email,
                                          'image': _imageFile,
                                          'fullname': fullname,
                                          'phonenumber': phonenumber,
                                          'gender': selectedGender,
                                          'location': state,
                                          'lga': lga,
                                          'agent': authprovider.agent,
                                        });

                                        setState(() {
                                          authprovider.imageFile = _imageFile;
                                          authprovider.fullname = fullname;
                                          authprovider.gender = selectedGender;
                                          authprovider.phonenumber =
                                              phonenumber;
                                          authprovider.location = state;
                                          authprovider.lga = lga;
                                          authprovider.selectedCountryCode = '';
                                          networkimage = true;
                                        });

                                        abnBox.put(
                                            "user", authprovider.getuser());
                                        setState(() {
                                          listingprovider
                                              .bottomSheetYesProcessing = false;
                                        });
                                        Navigator.pop(context);

                                        MyMessageHandler.showSnackBar(
                                            _scaffoldKey, "Saved!");
                                      } catch (e) {
                                        setState(() {
                                          listingprovider
                                              .bottomSheetYesProcessing = false;
                                        });
                                        print(e.toString());
                                        MyMessageHandler.showSnackBar(
                                            _scaffoldKey, e.toString());
                                      }
                                    },
                                  ),
                                );
                              }
                            } else {
                              MyMessageHandler.showSnackBar(
                                  _scaffoldKey, "Fill all fields");
                            }
                          },
                          padding: const EdgeInsets.all(0.0),
                          child: AnimatedOpacity(
                            opacity: processing ? 0.5 : 1,
                            duration: Duration(seconds: 1),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Constants.primaryColor,
                                  border:
                                      Border.all(color: Constants.primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
