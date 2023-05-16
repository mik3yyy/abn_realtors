import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_list/chat_list.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:v_chat_mention_controller/v_chat_mention_controller.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';
import '../../../provider/messages_provider.dart';
import '../../../settings/constants.dart';
import '../../../utils/GridDummyScreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  final DocumentSnapshot<Object?> user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  bool uninitialized = true;
  String? id = '';

  call(String number) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(widget.user["phonenumber"]);
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("WhatsApp is not installed on the device,"),
          backgroundColor: Constants.primaryColor,
        ),
      );
    }
  }

  _launchWhatsapp(String number) async {
    var whatsapp = number;
    var whatsappAndroid =
        Uri.parse("whatsapp://send?phone=$whatsapp&text=hello");
    try {
      bool launch = await canLaunchUrl(whatsappAndroid);
      if (launch) {
        try {
          await launchUrl(whatsappAndroid);
        } catch (e) {
          print(e.toString());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("WhatsApp is not installed on the device,"),
            backgroundColor: Constants.primaryColor,
          ),
        );
      }
    } catch (e) {
      print(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("WhatsApp is not installed on the device,"),
          backgroundColor: Constants.primaryColor,
        ),
      );
    }
  }

  final controller = VChatTextMentionController(
    debounce: 500,

    ///set custom style
    mentionStyle: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w800,
    ),
  );

  String parsedText = "";
  final logs = <String>[];

  var _fakeUsersDataServer = List.generate(100, (index) => "he $index");
  final users = <String>[];
  bool _isSearchCanView = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    getData();
    controller.onSearch = (str) async {
      print(users);
      users.clear();
      if (str != null) {
        //  print("search by $str");
        _isSearchCanView = true;
        if (str.isEmpty) {
          users.addAll(_fakeUsersDataServer);
        } else {
          //send request
          for (var element in _fakeUsersDataServer) {
            if (element.toLowerCase().startsWith(str.toLowerCase())) {
              // users.clear();
              users.add(element);
              print(users);
            }
          }
        }
      } else {
        //stop request
        _isSearchCanView = false;
      }
      setState(() {});
    };
  }

  void getData() async {
    await getAllDocumentsInCollection();
  }

  Future<void> getAllDocumentsInCollection() async {
    var messagesprovider =
        Provider.of<MessagesProvider>(context, listen: false);

    String letter1 = FirebaseAuth.instance.currentUser!.uid;
    String letter2 = widget.user.id;
    int result = letter1.compareTo(letter2);

    if (result < 0) {
      print('$letter1+$letter2');
      messagesprovider.chatid = '$letter1+$letter2';
    } else if (result > 0) {
      print('$letter2+$letter1');
      messagesprovider.chatid = '$letter2+$letter1';
    } else {
      print('$letter1+$letter2');
      messagesprovider.chatid = '$letter1+$letter2';
    }
    QuerySnapshot chatSnapshot = await _firestore.collection('chats').get();
    id = messagesprovider.chatid +
        "-" +
        chatSnapshot.docs.toList().length.toString();
    QuerySnapshot querySnapshot = await _firestore.collection('agents').get();

    if (querySnapshot.docs.isEmpty) {
      print('No documents found in the collection');
      _fakeUsersDataServer = [];
    } else {
      _fakeUsersDataServer = List.generate(querySnapshot.docs.length, (index) {
        var document = querySnapshot.docs[index];
        return document["fullname"];
      });
    }
  }

  ScrollController _scrollController = new ScrollController();
  bool once = true;
  void _scrollDown() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    var messagesprovider = Provider.of<MessagesProvider>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Scaffold(
        backgroundColor: listingprovider.getBackgroundColor(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: listingprovider.getBackgroundColor(),
          centerTitle: false,
          leadingWidth: 30,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left,
              size: 30,
              color: listingprovider.getForegroundColor(),
            ),
          ),
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  widget.user["image"],
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
            title: Text(
              widget.user["fullname"],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: listingprovider.getForegroundColor(),
              ),
            ),
            subtitle: Text(
              widget.user["agent"] ? "Agent" : "User",
              style: TextStyle(
                color: listingprovider.getForegroundColor(),
              ),
            ),
          ),
          actions: [
            Container(
              // margin: EdgeInsets.only(left: 10),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: IconButton(
                    onPressed: () {
                      _launchWhatsapp(widget.user["phonenumber"]);
                    },
                    icon: Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Constants.primaryColor,
                    )),
              ),
            ),
            Container(
              // margin: EdgeInsets.only(left: 10),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: IconButton(
                    onPressed: () async {
                      call(widget.user["phonenumber"]);
                    },
                    icon: Icon(
                      FontAwesomeIcons.phone,
                      color: Constants.primaryColor,
                    )),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Positioned(
                  bottom: 70,
                  top: 0,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: chats
                            .where("chatid", isEqualTo: messagesprovider.chatid)
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              uninitialized) {
                            return Container();
                          }

                          // if (snapshot.data!.docs.isEmpty) {
                          //   return const Center(
                          //       child: Text(
                          //         'This category \n\n has no items yet !',
                          //         textAlign: TextAlign.center,
                          //         style: TextStyle(
                          //             fontSize: 26,
                          //             color: Colors.blueGrey,
                          //             fontWeight: FontWeight.bold,
                          //             fontFamily: 'Acme',
                          //             letterSpacing: 1.5),
                          //       ));
                          // }
                          // print(snapshot.data!.docs.length.toString() + "heyy");

                          List<QueryDocumentSnapshot<Object?>> chats =
                              snapshot.data!.docs;

                          return ChatList(
                            scrollToTopButtonBuilder: (context) {
                              return Card(
                                margin: EdgeInsets.zero,
                                child: Container(
                                  width: 70,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5))),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_circle_down,
                                      color: Constants.primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },

                            msgCount: chats.length,
                            offsetToShowScrollToTop: 0,
                            offsetFromUnreadTipToTop: 0,
                            itemBuilder: (BuildContext context, int index) {
                              bool isMe = chats[index]["senderid"] ==
                                  FirebaseAuth.instance.currentUser!.uid;

                              int timestamp = chats[index]["createdAt"]
                                  .millisecondsSinceEpoch; // example timestamp
                              DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timestamp);
                              String formattedDate =
                                  '${date.month}/${date.day}/${date.year}';
                              String formattedTime =
                                  '${date.hour}:${date.minute} ${date.hour > 11 ? "PM" : "AM"}';

                              return Container(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: isMe == true
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      // width:  MediaQuery.of(context).size.width *0.6,
                                      padding: EdgeInsets.all(10),

                                      decoration: BoxDecoration(
                                        borderRadius: isMe == true
                                            ? const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              )
                                            : const BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                        color: isMe == true
                                            ? Colors.lightBlueAccent
                                            : Color(0xFFF0F0F0),
                                      ),
                                      constraints: BoxConstraints(
                                          minWidth: 10,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6),

                                      // padding : EdgeInsets
                                      child: Material(
                                        color: Colors.transparent,

                                        // elevation: 5.0,

                                        child: ParsedText(
                                          text: chats[index]["text"],
                                          style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black87),
                                          parse: <MatchText>[
                                            MatchText(
                                              type: ParsedType
                                                  .EMAIL, // predefined type can be any of this ParsedTypes
                                              style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                              ), // custom style to be applied to this matched text
                                              onTap: (url) {
                                                print("email");
// do something here with passed url
                                              }, // callback funtion when the text is tapped on
                                            ),
                                            MatchText(
                                              type: ParsedType
                                                  .URL, // predefined type can be any of this ParsedTypes
                                              style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                              ), // custom style to be applied to this matched text
                                              onTap: (url) {
                                                print("url");
// do something here with passed url
                                              }, // callback funtion when the text is tapped on
                                            ),
                                            MatchText(
                                              type: ParsedType
                                                  .PHONE, // predefined type can be any of this ParsedTypes
                                              style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                              ), // custom style to be applied to this matched text
                                              onTap: (url) {
                                                call(url);
                                                print("phone");
// do something here with passed url
                                              }, // callback funtion when the text is tapped on
                                            ),
                                            MatchText(
                                              pattern: r"\[(@[^:]+):([^\]]+)\]",
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                              renderWidget: (
                                                  {required pattern,
                                                  required text}) {
                                                return Text(text);
                                              },
// you must return a map with two keys
// [display] - the text you want to show to the user
// [value] - the value underneath it
                                              renderText: (
                                                  {required String str,
                                                  required String pattern}) {
                                                final map = <String, String>{};
                                                final RegExp customRegExp =
                                                    RegExp(
                                                        r"\[(@[^:]+):([^\]]+)\]");
                                                final match = customRegExp
                                                    .firstMatch(str);
                                                map['display'] =
                                                    match!.group(1)!;
                                                return map;
                                              },
                                              onTap: (url) {
                                                final customRegExp = RegExp(
                                                    r"\[(@[^:]+):([^\]]+)\]");
                                                final match = customRegExp
                                                    .firstMatch(url)!;
                                                final snackBar = SnackBar(
                                                  content: Text(
                                                      'id is ${match.group(2)} name is ${match.group(1)}'),
                                                  duration: const Duration(
                                                      seconds: 7),
                                                );

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onMsgKey: (int index) =>
                                snapshot.data!.docs[index].id,
                            // New message tip
                            showReceivedMsgButton: true,
                            // onIsReceiveMessage: (int i) => messages![i].type == MsgType.receive,
                            // Scroll to top
                            showScrollToTopButton: true,
                          );
                        }),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        topLeft: Radius.circular(5),
                      ),
                    ),
                    padding:
                        EdgeInsets.only(left: 20, right: 0, bottom: 20, top: 5),
                    child: Column(
                      children: [
                        Visibility(
                          visible: _isSearchCanView,
                          child: Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(),
                            child: ListView(
                              shrinkWrap: true,
                              children: users
                                  .map(
                                    (e) => ListTile(
                                      textColor: Colors.pink,
                                      onTap: () {
                                        controller.addMention(
                                          MentionData(
                                            id: "id-$e",
                                            display: e,
                                          ),
                                        );
                                      },
                                      title: Text(e),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              AnimatedContainer(
                                width: controller.text.isNotEmpty
                                    ? MediaQuery.of(context).size.width * 0.80
                                    : MediaQuery.of(context).size.width * 0.65,
                                constraints: BoxConstraints(
                                    maxHeight: 200, minHeight: 10),
                                duration: Duration(milliseconds: 0),
                                child: TextField(
                                    smartDashesType: SmartDashesType.enabled,
                                    smartQuotesType: SmartQuotesType.enabled,
                                    keyboardType: TextInputType.text,
                                    keyboardAppearance: Brightness.dark,
                                    minLines: 1,
                                    maxLines: 20,
                                    onChanged: (String value) {
                                      setState(() {
                                        uninitialized = false;
                                      });
                                    },
                                    controller: controller,
                                    cursorWidth: 1,
                                    decoration:
                                        Constants.textFormDecoration.copyWith(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      hintText: "",
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    )),
                              ),
                              if (controller.text.isNotEmpty)
                                IconButton(
                                  onPressed: () async {
                                    messagesprovider.type =
                                        messagesprovider.Type[0];
                                    messagesprovider.text = controller.text;
                                    messagesprovider.senderid =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    messagesprovider.receiverid =
                                        widget.user.id;

                                    // print(messagesprovider.sendMessage());

                                    String text = controller.text;
                                    setState(() {
                                      // logs.add(controller.markupText);
                                      controller.clear();
                                    });

                                    try {
                                      String uid = Uuid().v4();
                                      await chats
                                          .doc(uid)
                                          .set(messagesprovider.sendMessage());
                                      // QuerySnapshot chatSnapshot = await _firestore.collection('chats').get();
                                      // id=  messagesprovider.chatid +"-"+ chatSnapshot.docs.toList().length.toString();
                                    } catch (e) {
                                      setState(() {
                                        controller.text = text;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.send,
                                    color: Constants.primaryColor,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  splashColor: Colors.white,
                                  splashRadius: 1,
                                ),
                              if (controller.text.isEmpty)
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Constants.primaryColor,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  splashColor: Colors.white,
                                  splashRadius: 1,
                                ),
                              if (controller.text.isEmpty)
                                AnimatedCrossFade(
                                  secondChild: Container(),
                                  crossFadeState: controller.text.isEmpty
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  firstChild: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.attach_file,
                                        color: Constants.primaryColor,
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      splashColor: Colors.white,
                                      splashRadius: 1),
                                  duration: Duration(milliseconds: 0),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
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


//
// ListTile(
// title:
// ParsedText(
// text: logs[index],
// style: const TextStyle(color: Colors.black87),
// parse: <MatchText>[
// MatchText(
// type: ParsedType.EMAIL, // predefined type can be any of this ParsedTypes
// style: TextStyle(
// color: Colors.blue,
//
//
// decoration: TextDecoration.underline,
// ), // custom style to be applied to this matched text
// onTap: (url) {
//
// print("email");
// // do something here with passed url
// }, // callback funtion when the text is tapped on
// ),
// MatchText(
// type: ParsedType.URL, // predefined type can be any of this ParsedTypes
// style: TextStyle(
// color: Colors.blue,
//
//
// decoration: TextDecoration.underline,
// ), // custom style to be applied to this matched text
// onTap: (url) {
// print("url");
// // do something here with passed url
// }, // callback funtion when the text is tapped on
// ),
// MatchText(
// type: ParsedType.PHONE, // predefined type can be any of this ParsedTypes
// style: TextStyle(
// color: Colors.blue,
//
//
// decoration: TextDecoration.underline,
//
// ), // custom style to be applied to this matched text
// onTap: (url) {
// call(url);
// print("phone");
// // do something here with passed url
// }, // callback funtion when the text is tapped on
// ),
//
//
// MatchText(
// pattern: r"\[(@[^:]+):([^\]]+)\]",
// style: const TextStyle(
// color: Colors.blue,
//
//
//
// ),
// renderWidget: ({required pattern, required text}) {
// return Text(text);
// },
// // you must return a map with two keys
// // [display] - the text you want to show to the user
// // [value] - the value underneath it
// renderText: ({required String str, required String pattern}) {
// final map = <String, String>{};
// final RegExp customRegExp =
// RegExp(r"\[(@[^:]+):([^\]]+)\]");
// final match = customRegExp.firstMatch(str);
// map['display'] = match!.group(1)!;
// return map;
// },
// onTap: (url) {
// final customRegExp = RegExp(r"\[(@[^:]+):([^\]]+)\]");
// final match = customRegExp.firstMatch(url)!;
// final snackBar = SnackBar(
// content: Text(
// 'id is ${match.group(2)} name is ${match.group(1)}'),
// duration: const Duration(seconds: 7),
// );
//
// ScaffoldMessenger.of(context).showSnackBar(snackBar);
// },
// ),
// ],
//
// ),
// ),



















//
// Row(
// mainAxisAlignment:isMe? MainAxisAlignment.end: MainAxisAlignment.start,
// children: [
// Flexible(
// child: Container(
// // width: MediaQuery.of(context).size.width*0.7,
//
//
//
// margin: EdgeInsets.all(10),
// padding: EdgeInsets.all(10),
// decoration: BoxDecoration(
// color: isMe? Constants.primaryColor: Constants.greyColor,
//
// borderRadius:isMe? BorderRadius.only(
// topLeft: Radius.circular(30),
// bottomLeft: Radius.circular(30),
// bottomRight: Radius.circular(30),
// ):  BorderRadius.only(
// topLeft: Radius.circular(0),
// bottomLeft: Radius.circular(30),
// bottomRight: Radius.circular(30),
// topRight: Radius.circular(30),
// ),
// ),
// child: FittedBox(
//
// child: ParsedText(
// text: chats[index]["text"],
// maxLines: 10,
//
//
// style:  TextStyle(color: isMe? Colors.white: Colors.black,fontSize: 24 ),
// parse: <MatchText>[
// MatchText(
// type: ParsedType.EMAIL, // predefined type can be any of this ParsedTypes
// style: TextStyle(
// color: Colors.blue,
//
//
// decoration: TextDecoration.underline,
// ), // custom style to be applied to this matched text
// onTap: (url) {
//
// print("email");
// // do something here with passed url
// }, // callback funtion when the text is tapped on
// ),
// MatchText(
// type: ParsedType.URL, // predefined type can be any of this ParsedTypes
// style: TextStyle(
// color: Colors.blue,
//
//
// decoration: TextDecoration.underline,
// ), // custom style to be applied to this matched text
// onTap: (url) {
// print("url");
// // do something here with passed url
// }, // callback funtion when the text is tapped on
// ),
// MatchText(
// type: ParsedType.PHONE, // predefined type can be any of this ParsedTypes
// style: TextStyle(
// color: Colors.blue,
//
//
// decoration: TextDecoration.underline,
//
// ), // custom style to be applied to this matched text
// onTap: (url) {
// call(url);
// print("phone");
// // do something here with passed url
// }, // callback funtion when the text is tapped on
// ),
//
//
// MatchText(
// pattern: r"\[(@[^:]+):([^\]]+)\]",
// style: const TextStyle(
// color: Colors.blue,
//
//
//
// ),
// renderWidget: ({required pattern, required text}) {
// return Text(text);
// },
// // you must return a map with two keys
// // [display] - the text you want to show to the user
// // [value] - the value underneath it
// renderText: ({required String str, required String pattern}) {
// final map = <String, String>{};
// final RegExp customRegExp =
// RegExp(r"\[(@[^:]+):([^\]]+)\]");
// final match = customRegExp.firstMatch(str);
// map['display'] = match!.group(1)!;
// return map;
// },
// onTap: (url) {
// final customRegExp = RegExp(r"\[(@[^:]+):([^\]]+)\]");
// final match = customRegExp.firstMatch(url)!;
// final snackBar = SnackBar(
// content: Text(
// 'id is ${match.group(2)} name is ${match.group(1)}'),
// duration: const Duration(seconds: 7),
// );
//
// ScaffoldMessenger.of(context).showSnackBar(snackBar);
// },
// ),
// ],
// // softWrap: false,
// // overflow: TextOverflow.ellipsis,
//
//
// ),
// fit: BoxFit.fitHeight,
// ),
//
// ),
// ),
// ],
// );
