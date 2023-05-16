import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
class MessagesProvider with ChangeNotifier {

  List<String> currentChat=[];




  /////////////////////////////////
  String chatid="";
  String text='';
  List<String> images=[];
  List<String> file= [];

  List<String> Type=["text","image", "images", "file", "post"];
  
  
  String type="";
  String senderid ="";
  String receiverid="";

  bool read = false;

  Map<String, dynamic> message ={};


  Map<String, dynamic> sendMessage(){

    
    if (type== Type[0]){
      message= {
        "chatid": chatid,
        "type": type,
        "text": text,
        // "images": images,
        // "files": files,
        "senderid": senderid,
        "receiverid": receiverid,
        "createdAt":  Timestamp.now(),
        "read": false
      };
    }
    else if (type== Type[1]){
      message= {
        "chatid": chatid,
        "type": type,
        "text": text,
        "images": images,
        // "files": files,
        "senderid": senderid,
        "receiverid": receiverid,
        "createdAt":Timestamp.now(),
        "read": false
      };
    }
    else if (type== Type[2]){
      message= {
        "chatid": chatid,
        "type": type,
        "text": text,
        "images": images,
        "images-length": images.length,
        // "files": files,
        "senderid": senderid,
        "receiverid": receiverid,
        "createdAt": Timestamp.now(),
        "read": false
      };
    }
    else if (type== Type[3]){
      message= {
        "chatid": chatid,
        "type": type,
        "text": text,
        "images": images,
        "images-length": images.length,
        "files": file,
        "senderid": senderid,
        "receiverid": receiverid,
        "createdAt": Timestamp.now(),
        "read": false
      };
    }
    else if (type== Type[4]){
      message= {
        "chatid": chatid,
        "type": type,
        "text": text,
        "images": images,
        "images-length": images.length,
        // "files": files,
        "senderid": senderid,
        "receiverid": receiverid,
        "createdAt": Timestamp.now(),
        "read": false
      };
    }
    return message;

  }



}
