
import 'package:abn_realtors/authentication_screens/agent/verrifyemail.dart';
import 'package:abn_realtors/authentication_screens/user/verrifyemail.dart';
import 'package:abn_realtors/provider/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../provider/main_provider.dart';
import '../../settings/constants.dart';
import 'dart:io';
import '../../settings/messageHandler.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
class FillAgentProfile extends StatefulWidget {
  const FillAgentProfile({Key? key}) : super(key: key);

  @override
  State<FillAgentProfile> createState() => _FillAgentProfileState();
}

class _FillAgentProfileState extends State<FillAgentProfile> {
  String? selectedLGA ;
  final TextEditingController textEditingController = TextEditingController();
  String selectedState =  "Lagos";
  final TextEditingController StateEditingController = TextEditingController();

  //Global keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();

// local var
  String selectedCode = '+234';
  String selectedGender = 'Male';
  final ImagePicker _picker = ImagePicker();
  String _imageFile ='';
  dynamic _pickedImageError;

  //firebase
  String _uid = '';
  CollectionReference customers =
  FirebaseFirestore.instance.collection('agents');

//hive
  final abnBox = Hive.box('abn');

bool processing = false;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    var authprovider = Provider.of<AuthProvider>(context, listen: false);

    selectedState =  authprovider.location.isNotEmpty? authprovider.location :"Lagos" ;
    selectedLGA = authprovider.lga.isNotEmpty? authprovider.lga : null;
    _imageFile = Provider.of<AuthProvider>(context, listen: false).imageFile;
    selectedGender = Provider.of<AuthProvider>(context, listen: false).gender;
  }

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    print(authprovider.getuser());

    ////////////////////////////////////
    void _pickImageFromCamera() async {

      try {
        final pickedImage = await _picker.pickImage(
            source: ImageSource.camera,
            maxHeight: 300,
            maxWidth: 300,
            imageQuality: 95);
        setState(() {

          _imageFile = pickedImage!.path;
          authprovider.imageFile = _imageFile;


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
        if (pickedImage!.path != null){
          setState(() {
            _imageFile = pickedImage.path;
            authprovider.imageFile = _imageFile;
          });
        }
      } catch (e) {
        setState(() {
          _pickedImageError = e;
        });
        print(_pickedImageError);
      }
    }
////////////////////////////////////////////

    /////////////////////////////////////////////////////
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
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
    ////////////////////////////////////////////////
    void Proceed() async {

      if (_formKey.currentState!.validate() && selectedLGA!.isNotEmpty) {

        if (_imageFile.isNotEmpty){

          authprovider.gender = selectedGender;
          authprovider.selectedCountryCode = selectedCode;
          authprovider.imageFile = _imageFile;

          if (authprovider.phonenumber[0] == '0'){

            authprovider.phonenumber=   authprovider.phonenumber.substring(1);
            print(authprovider.phonenumber);
          }
          else {
            authprovider.phonenumber=  authprovider.phonenumber;
          }
          setState(() {
            processing = true;
          });
          try {
            if(FirebaseAuth.instance.currentUser == null ){
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: authprovider.email, password: authprovider.password);
            }
            firebase_storage.Reference ref = firebase_storage
                .FirebaseStorage.instance
                .ref('agent-images/${authprovider.email}.jpg');



            await ref.putFile(File(_imageFile));
            authprovider.imageFile = await ref.getDownloadURL();


            _uid = FirebaseAuth.instance.currentUser!.uid;
            setState(() {
              authprovider.agent = true;
            });

            await customers.doc(_uid).set(authprovider.getuser());


            abnBox.put("user",authprovider.getuser());


            ///////////////////////////////////////////
            Navigator.pushNamed(context,VerifyAgentEmail.id);


          } on FirebaseAuthException catch (e) {


            if (e.code == 'weak-password') {
              setState(() {
                processing = false;
              });
              MyMessageHandler.showSnackBar(_scaffoldKey, 'The password provided is too weak.');
            }
            else if (e.code == 'email-already-in-use') {
              setState(() {
                processing = false;
              });
              MyMessageHandler.showSnackBar(_scaffoldKey, 'The account already exists for that email.');
            } else {
              setState(() {
                processing = false;
              });
              MyMessageHandler.showSnackBar(_scaffoldKey, e.toString());
            }
          }

        } else {

          MyMessageHandler.showSnackBar(_scaffoldKey, "Select a profile picture 🌄");

        }

      } else {
        MyMessageHandler.showSnackBar(_scaffoldKey, "There seems to be an issue 😟");
      }
    }
      List<String>? state = Constants.statesMap[selectedState]!.toList();



    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: listingprovider.getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: listingprovider.getBackgroundColor(),
          elevation: 0,
          leading: IconButton(
            onPressed: () { Navigator.pop(context); },
            icon: Icon(Icons.chevron_left,color: listingprovider.getForegroundColor(),size: 35,),

          ),
          title: Text('Fill your profile',
              style: TextStyle(
              color: listingprovider.getForegroundColor(),

          ),
          ),
        ),
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

                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade400,
                      backgroundImage: _imageFile.isEmpty
                          ? null
                          :  FileImage(File(_imageFile)),
                      child: _imageFile.isEmpty
                          ? Icon(Icons.person, size: 60, color: listingprovider.getBackgroundColor())
                          : Container(),



                    ),


                    SizedBox(width: 20,),
                    Column(
                      children: [
                        Container(
                          decoration:  BoxDecoration(
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
                          decoration:  BoxDecoration(
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
                SizedBox(height: 30,),

                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full name',
                      style: TextStyle(
                        color: listingprovider.getForegroundColor()
                      ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5,bottom: 15),
                        child: TextFormField(
                          initialValue: authprovider.fullname,
                          onChanged: (String ? value){
                            authprovider.fullname = value!;
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

                              hintText: 'Okpechi Michael',
                              enabledBorder: OutlineInputBorder(

                                  borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                borderRadius: BorderRadius.circular(20),

                              ),
                            )
                        ),
                      ),
                      Text('Phone number',
                        style: TextStyle(
                            color: listingprovider.getForegroundColor()
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5,bottom: 15),
                        child: TextFormField(
                          initialValue: authprovider.phonenumber,
                          validator: (String? value ){
                            if (value!.isEmpty){

                              return 'enter your phone number';
                            } else if  (value.length < 10){
                              return 'invalid phone number ';
                            }

                            else {
                              return null;
                            }

                          },
                            style: TextStyle(
                                color: listingprovider.getForegroundColor()
                            ),
                            onChanged: (String? value){
                            authprovider.phonenumber = value!;

                            },
                            decoration: Constants.textFormDecoration.copyWith(
                              prefixIconColor: listingprovider.getForegroundColor(),
                              prefixIcon: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  hint: Text(
                                    'Select Item',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  items: items
                                      .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedCode,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCode = value as String;
                                    });
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    height: 40,
                                    width: 100,
                                  ),
                                  alignment: AlignmentDirectional.center,

                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                  ),
                                ),
                              ),
                              hintText: 'Phone number',
                              enabledBorder: OutlineInputBorder(

                                  borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                borderRadius: BorderRadius.circular(20),

                              ),
                            )
                        ),
                      ),
                      Text('Gender',
                        style: TextStyle(
                            color: listingprovider.getForegroundColor()
                        ),
                      ),
                      Padding(

                        padding: EdgeInsets.only(top: 5,bottom: 15),
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
                                  items: genders
                                      .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedGender,
                                  onChanged: (value) {
                                    setState(() {


                                      selectedGender = value as String;
                                      authprovider.gender = selectedGender;
                                      print(authprovider.gender);
                                    });
                                  },
                                  alignment: AlignmentDirectional.center,

                                  buttonStyleData:  ButtonStyleData(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                  ),
                                ),
                              ),
                              hintText: 'Select Gender',
                              enabledBorder: OutlineInputBorder(

                                  borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                borderRadius: BorderRadius.circular(20),

                              ),
                            )
                        ),
                      ),
                      Text('State',
                      style: TextStyle(
                        color: listingprovider.getForegroundColor()
                      ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5,bottom: 15),
                        child: TextFormField(
                          initialValue: authprovider.location,

                            onChanged: (String ? value){
                              authprovider.location = value!;
                            },

                            style: TextStyle(
                                color: listingprovider.getForegroundColor()
                            ),
                            decoration: Constants.textFormDecoration.copyWith(
                              prefixIcon:  DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Item',
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
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedState,
                                  onChanged: (value) {
                                    setState(() {
                                      state = Constants.statesMap[value]!.toList();
                                      print(state);
                                      selectedLGA = null;
                                      authprovider.lga='';

                                      selectedState = value as String;
                                      authprovider.location = value;

                                    });
                                  },
                                  alignment: AlignmentDirectional.center,

                                  buttonStyleData:  ButtonStyleData(
                                    padding: EdgeInsets.only(left: 10),
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  dropdownStyleData:  DropdownStyleData(
                                    maxHeight: 200,
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                  ),
                                  dropdownSearchData: DropdownSearchData(
                                    searchController: StateEditingController,
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
                                        controller: StateEditingController,
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
                                      StateEditingController.clear();
                                    }
                                  },
                                ),
                              ),
                              hintText: 'State',
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),

                                  borderSide: BorderSide(color:  listingprovider.getForegroundColor(),)
                              ),
                            )
                        ),
                      ),
                      Text('LGA',
                        style: TextStyle(
                            color: listingprovider.getForegroundColor()
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5,bottom: 15),
                        child: TextFormField(
                          initialValue: authprovider.lga,

                            onChanged: (String ? value){
                              authprovider.lga = value!;
                            },
                            // validator: (String? value){
                            //   if (value!.isEmpty){
                            //     return 'enter your local government area';
                            //   } else {
                            //     return null;
                            //   }
                            // },
                            style: TextStyle(
                                color: listingprovider.getForegroundColor()
                            ),
                            decoration: Constants.textFormDecoration.copyWith(
                              prefixIcon: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Item',
                                    style: TextStyle(

                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  items:
                                  state?.map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedLGA,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLGA = value as String;
                                      authprovider.lga = value;
                                    });
                                  },
                                  alignment: AlignmentDirectional.center,

                                  buttonStyleData:  ButtonStyleData(
                                    padding: EdgeInsets.only(left: 10),
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  dropdownStyleData:  DropdownStyleData(
                                    maxHeight: 200,
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

                              hintText: 'Local Government Area',
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                borderRadius: BorderRadius.circular(20),

                              ),
                            )
                        ),
                      ),
                      Opacity(
                        opacity: processing? 0.5 : 1,
                        child: MaterialButton(
                          onPressed: (){
                            Proceed();

                          },
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            height: 50,
                            decoration:  BoxDecoration(
                                color: Constants.primaryColor,
                                border: Border.all(color: Constants.primaryColor),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child:  Stack(

                              children: [
                                Center(
                                  child: Text("Proceed",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                                if(processing)
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: LoadingAnimationWidget.hexagonDots(
                                      color: listingprovider.getForegroundColor(),
                                      // rightDotColor: Constant.generalColor,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 100,)



                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
