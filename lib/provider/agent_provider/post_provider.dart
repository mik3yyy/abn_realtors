import 'dart:io';

import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_AddProperties_Screen/post_property.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class PostProvider with ChangeNotifier {
  PageController pageController = PageController(initialPage: 0);
  List<String> imageFiles  =[];
  List<String> imageUrls =[];
  bool sold= false;
  String title = '';
  String description = '';
  String state ='';
  String lga ='';
  String price = '';
  List<String> Categories = [];
  List<String> categories = ["Raw land", "Terrace", "Semi-detached", "Building", "Apartment", "Office Space", "Mansion","Penthouse" ,"Others"];

  List<bool> checks = [false,false,false,false,false,false,false,false,false];


  String bedroom = '';
  String toilet ='';
  String floors = '';
  String pid ='';
  String uid ='';



  ///////////////////////RAW LAND
  String length ='';
  String breath ='';
  List proof =["COO", "Deed","Building permit"];
  String selected="";
  File ? Proof;


  ////////BUilding
  List<String> subcategory = ["Duplex", "Bungalow"];
  String subSelected="";



///////////////////// OFFICES SPACE
  String rooms = "" ;

  //////////// OTHERS
  String type="";





  Map <String, dynamic > post ={};




  void addImage(String image){
    imageFiles.add(image);
    notifyListeners();
  }
  void removeImage(int index ){
    imageFiles.removeAt(index);
    notifyListeners();
  }

  Map<String, dynamic> getProperty(){
    if(Categories[0]==categories[0]){
      /////RAW LAND

      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "length": length,
        "breath":breath,
        "imageUrls": imageUrls,
        "proof": Proof,
        "type": selected,
        "sold":sold,
        "createdAt": Timestamp.now(),

      };

    }
    else if (Categories[0]==categories[1]) {
      /////Terrace
      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "floors":floors,
        "bedroom":bedroom,
        "toilet": toilet,
        "imageUrls": imageUrls,
        "sold":sold,
        "createdAt": Timestamp.now(),



      };
    }
    else if (Categories[0]==categories[2]) {
      /////Semi-detached
      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "floors":floors,
        "bedroom":bedroom,
        "toilet": toilet,
        "imageUrls": imageUrls,
        "sold":sold,
        "createdAt": Timestamp.now(),


      };
    }
    else if (Categories[0]==categories[3]) {
      //Building
      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "subCategory": subSelected,
        "floors":floors,
        "bedroom":bedroom,
        "toilet": toilet,
        "imageUrls": imageUrls,
        "sold":sold,
        "createdAt": Timestamp.now(),

      };

    }
    else if (Categories[0]==categories[4]) {
//Apartment
      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "floors":floors,
        "bedroom":bedroom,
        "toilet": toilet,
        "imageUrls": imageUrls,
        "sold":sold,
        "createdAt": Timestamp.now(),

      };

    }
    else if (Categories[0]==categories[5]) {
//Office Space
      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "floors":floors,
        "rooms":rooms,
        "toilet": toilet,
        "imageUrls": imageUrls,
        "sold":sold,
        "createdAt": Timestamp.now(),

      };

    }
    else if (Categories[0]==categories[6]) {
//Mansion
      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "floors":floors,
        "bedroom":bedroom,
        "toilet": toilet,
        "imageUrls": imageUrls,
        "sold":sold,
        "createdAt": Timestamp.now(),

      };

    }else if (Categories[0]==categories[7]) {
//Penthouse
      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "floors":floors,
        "bedroom":bedroom,
        "toilet": toilet,
        "imageUrls": imageUrls,
        "sold":sold,
        "createdAt": Timestamp.now(),

      };

    }else if (Categories[0]==categories[8]) {
//Others
      post ={
        "uid":uid,
        "pid": pid,
        "title": title,
        "description":description,
        "state":state,
        "lga": lga,
        "price":price,
        "Category":Categories.first,
        "type":type,
        "imageUrls": imageUrls,
        "sold":sold,
        "createdAt": Timestamp.now(),

      };

    }




   return post;
    //
    // post ={
    //  "uid":uid,
    //  "pid": pid,
    //   "title": title,
    //  "description":description,
    //  "state":state,
    //  "lga": lga,
    //  "price":price,
    //  "Category":Categories.first,
    //  "length": length,
    //  "breath":breath,
    //  "floors":floors,
    //  "rooms":rooms,
    //  "toilet": toilet,
    //  "imageUrls": imageUrls,
    //   "sold":sold
    //
    //
    //
    // };


  }

  void clear(){
     imageFiles  =[];
     imageUrls =[];
     checks = [false,false,false,false,false,false,false,false,false,false];
     title = '';
     description = '';
     state ='';
     lga ='';
     price = '';
     Categories = [];
     length ='';
     breath ='';
     bedroom = '';
     toilet ='';
     floors = '';
     pid ='';
     uid ='';
  }


  String checkData(){

    if(Categories[0]==categories[0]){
      /////RAW LAND
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice() &&
            length.isNotEmpty && breath.isNotEmpty ) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }

    }
    else if (Categories[0]==categories[1]) {
      /////Terrace
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice() &&
            bedroom.isValidQuantity() &&
            toilet.isValidQuantity() &&
            floors.isValidQuantity()) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }
    }
    else if (Categories[0]==categories[2]) {
      /////Semi-detached
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice() &&
            bedroom.isValidQuantity() &&
            toilet.isValidQuantity() &&
            floors.isValidQuantity()) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }
    }
    else if (Categories[0]==categories[3]) {
      //Building
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice() &&
            bedroom.isValidQuantity() &&
            toilet.isValidQuantity() &&
            floors.isValidQuantity()) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }
    }
    else if (Categories[0]==categories[4]) {
//Apartment
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice() &&
            bedroom.isValidQuantity() &&
            toilet.isValidQuantity() &&
            floors.isValidQuantity()) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }
    }
    else if (Categories[0]==categories[5]) {
//Office Space
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice() &&
            rooms.isValidQuantity() &&
            toilet.isValidQuantity() &&
            floors.isValidQuantity()) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }
    }
    else if (Categories[0]==categories[6]) {
//Mansion
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice() &&
            bedroom.isValidQuantity() &&
            toilet.isValidQuantity() &&
            floors.isValidQuantity()) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }
    }
   else if (Categories[0]==categories[7]) {
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice() &&
            bedroom.isValidQuantity() &&
            toilet.isValidQuantity() &&
            floors.isValidQuantity()) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }
//Penthouse

    }else if (Categories[0]==categories[8]) {
//Others
      if(title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && state.isNotEmpty && lga.isNotEmpty && Categories.isNotEmpty  ) {
        if (price.isValidPrice()
           ) {

          return "";

        } else {
          return "input valid digits ";
        }


      } else {
        return "fill all field";
      }

    } else {
      return "unknown";
    }
  }









}