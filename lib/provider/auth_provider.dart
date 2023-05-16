import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {

  String email = '' ;
  String password = '' ;
  String imageFile = '';
  String fullname='';
  String phonenumber = '';
  String gender = 'Male';
  String location ='';
  String lga ='';
  String selectedCountryCode ='';
  bool agent = false;
  bool rememberme  = true;
  // bool googleimage = false;

  Map<String, dynamic> user ={};

  Map<String, dynamic> getuser() {

    user ={
    'email' : email,
    'image' : imageFile,
    'fullname' : fullname,
    'phonenumber' : selectedCountryCode+ phonenumber,
    'gender' : gender,
    'location': location,
    'lga': lga,
      'agent': agent,
  };

    return user;
  }

  void fillData(Map <dynamic, dynamic> newuser){

    email = newuser['email'];
    imageFile = newuser['image'];
    fullname = newuser['fullname'];
    phonenumber = newuser['phonenumber'];
    gender = newuser['gender'];
    location = newuser['location'];
    lga = newuser['lga'];
    agent = newuser['agent'];

  }

  void UserSignOut (){

    user = {};
    email = '' ;
    password = '' ;
    imageFile = '';
    fullname='';
    phonenumber = '';
    gender = 'Male';
    location ='';
    lga ='';
    selectedCountryCode ='';
    agent = false;

  }


}