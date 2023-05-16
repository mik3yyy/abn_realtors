import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_messages_screen/chart_screen.dart';
import 'package:abn_realtors/settings/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';
import '../../../utils/ListDummyScreen.dart';
import '../../../utils/property_card.dart';
import '../Agent_Home_Screen/view_property.dart';
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:async/async.dart';

class AddMessage extends StatefulWidget {
  const AddMessage({Key? key}) : super(key: key);

  @override
  State<AddMessage> createState() => _AddMessageState();
}

class _AddMessageState extends State<AddMessage> {
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

  final TextEditingController SearchController = TextEditingController();

  String search = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    Stream<QuerySnapshot> getData() {
      Stream<QuerySnapshot> _agentStream =
          FirebaseFirestore.instance.collection('agents').snapshots();
      Stream<QuerySnapshot> _userStream =
          FirebaseFirestore.instance.collection('customers').snapshots();

      return StreamGroup.mergeBroadcast([
        _userStream,
        _agentStream,
      ]);
    }

    Stream<QuerySnapshot> _agentStream =
        FirebaseFirestore.instance.collection('agents').snapshots();
    Stream<QuerySnapshot> _userStream =
        FirebaseFirestore.instance.collection('customers').snapshots();

    final mergedStream = Rx.combineLatest2(_agentStream, _userStream,
        (QuerySnapshot query1, QuerySnapshot query2) {
      // Combine the two query snapshots into a single list
      List<DocumentSnapshot> documents = [];

      print("hello");
      documents.addAll(query1.docs);
      documents.addAll(query2.docs);
      // documents = documents.shuffle()
      return documents;
    });

    return Container(
      color: listingprovider.lightMode
          ? Colors.white.withOpacity(0)
          : listingprovider.getBackgroundColor(),
      height: MediaQuery.of(context).size.height * 0.95,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        backgroundColor: listingprovider.lightMode
            ? Colors.white.withOpacity(0)
            : listingprovider.getBackgroundColor(),
        body: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color:
                  listingprovider.lightMode ? Colors.white : Color(0xFF303134),
            ),
            child: Scaffold(
              backgroundColor:
                  listingprovider.lightMode ? Colors.white : Color(0xFF303134),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: listingprovider.lightMode
                    ? Colors.white
                    : Color(0xFF303134),
                leading: Container(),
                title: Text(
                  "New Chat",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: listingprovider.getForegroundColor()),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: Constants.primaryColor,
                      )),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 5, bottom: 15, right: 10, left: 10),
                    child: TextFormField(
                        controller: SearchController,
                        onChanged: (String value) {
                          print(value);
                          setState(() {
                            search = value;
                          });
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
                          suffixIcon: Icon(Icons.search),
                          hintText: 'serach user or agent',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: listingprovider.getForegroundColor(),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    search == ''
                        ? Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25)),
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Text(
                                      '',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ]),
                            ),
                          )
                        : StreamBuilder<List<DocumentSnapshot>>(
                            stream: mergedStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<DocumentSnapshot>>
                                    snapshot) {
                              print(snapshot.hasData);

                              if (snapshot.hasError) {
                                return ListDummyScreen();
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ListDummyScreen();
                              }

                              if (snapshot.data!.isEmpty) {
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

                              var result = snapshot.data!.where((e) {
                                return e['fullname']
                                    .toString()
                                    .toLowerCase()
                                    .contains(search.toLowerCase());
                              });

                              result = result.where((e) {
                                return e["email"].toString() !=
                                    authprovider.email;
                              });

                              List<DocumentSnapshot<Object?>>? user =
                                  result.toList();

                              return Container(
                                height: 270,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: user.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                        user: user[index],
                                                      )));
                                        },
                                        child: Container(
                                          height: 70,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(60),
                                                child: Image.network(
                                                  user[index]["image"],
                                                  fit: BoxFit.fill,
                                                  loadingBuilder: (context,
                                                      child, loading) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey),
                                                      child: child,
                                                    );
                                                  },
                                                  errorBuilder:
                                                      (context, object, error) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              user[index]["fullname"],
                                              style: TextStyle(
                                                color: listingprovider
                                                    .getForegroundColor(),
                                              ),
                                            ),
                                            subtitle: Text(
                                              user[index]["agent"]
                                                  ? "Agent"
                                                  : "User",
                                              style: TextStyle(
                                                color: listingprovider
                                                    .getForegroundColor(),
                                              ),
                                            ),
                                            // trailing:  Container(
                                            //   // margin: EdgeInsets.only(left: 10),
                                            //   width: 40,
                                            //   height: 40,
                                            //   decoration: BoxDecoration(
                                            //       color: Colors.lightBlueAccent.withOpacity(0),
                                            //       borderRadius: BorderRadius.circular(10)
                                            //
                                            //   ),
                                            //   child: Center(
                                            //     child: IconButton( onPressed: (){
                                            //       _launchWhatsapp(user[index]["phonenumber"]);
                                            //     }, icon: Icon(FontAwesomeIcons.whatsapp,color: Colors.green,)),
                                            //   ),
                                            // ),
                                          ),
                                        ),
                                      );
                                    }),
                              );
                            },
                          ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
