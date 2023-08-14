import 'package:abn_realtors/main_screens/messages_screen/add_message_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../../provider/auth_provider.dart';
import '../../provider/main_provider.dart';
import '../../provider/messages_provider.dart';
import '../../settings/constants.dart';
import '../../utils/GridDummyScreen.dart';
import 'chart_screen.dart';
import '../../utils/ListDummyScreen.dart';
import '../../utils/empty_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    var messagesprovider = Provider.of<MessagesProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: listingprovider.getBackgroundColor(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: listingprovider.getBackgroundColor(),
        title: Text(
          "Messages",
          style: TextStyle(color: listingprovider.getForegroundColor()),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.black38.withOpacity(0),
                isScrollControlled: true,
                builder: (context) => AddMessage(),
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: Constants.primaryColor,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(authprovider.email)
              .orderBy("time", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return ListDummyScreen();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListDummyScreen();
            }

            List<QueryDocumentSnapshot<Object?>> chats = snapshot.data!.docs;

            return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  // print(chats[index]["isAgent"]);
                  return StreamBuilder<QuerySnapshot>(
                      stream: chats[index]["isAgent"]
                          ? FirebaseFirestore.instance
                              .collection("agents")
                              .where("email", isEqualTo: chats[index]["email"])
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection("customers")
                              .where("email", isEqualTo: chats[index]["email"])
                              .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return ListDummyScreen();
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListDummyScreen();
                        }

                        int timestamp = chats[index]["time"]
                            .millisecondsSinceEpoch; // example timestamp
                        DateTime date =
                            DateTime.fromMillisecondsSinceEpoch(timestamp);
                        DateTime today = Timestamp.now().toDate();

                        String todayStr =
                            "${today.day}-${today.month}-${today.year}";
                        String dateStr =
                            "${date.day}-${date.month}-${date.year}";

                        String formattedDate =
                            '${date.month}/${date.day}/${date.year}';
                        String formattedTime =
                            '${date.hour}:${date.minute} ${date.hour > 11 ? "PM" : "AM"}';

                        return ListTile(
                          onTap: () {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) async {
                              // chats[index][id]
                              CollectionReference myChats = FirebaseFirestore
                                  .instance
                                  .collection(authprovider.email);

                              await myChats
                                  .doc(chats[index]["email"])
                                  .update({"read": true});
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        user: snapshot.data!.docs[0])));
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.network(
                                  chats[index]["image"],
                                  fit: BoxFit.fill,
                                  loadingBuilder: (context, child, loading) {
                                    return Container(
                                      decoration:
                                          BoxDecoration(color: Colors.grey),
                                      child: child,
                                    );
                                  },
                                  errorBuilder: (context, object, error) {
                                    return Container(
                                      decoration:
                                          BoxDecoration(color: Colors.grey),
                                    );
                                  },
                                )),
                          ),
                          title: Text(
                            chats[index]["name"],
                            style: TextStyle(
                                color: listingprovider.getForegroundColor(),
                                fontWeight: FontWeight.w400,
                                fontSize: 15),
                          ),
                          subtitle: Text(
                            chats[index]["text"],
                            style: TextStyle(
                                color: listingprovider.getForegroundColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                          trailing: Container(
                            height: 40,
                            child: Column(
                              mainAxisAlignment: chats[index]["read"]
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  todayStr == dateStr
                                      ? formattedTime
                                      : formattedDate,
                                  style: TextStyle(
                                    color: listingprovider.getForegroundColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                                chats[index]["read"]
                                    ? Container(
                                        height: 2,
                                        width: 2,
                                      )
                                    : CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Constants.primaryColor,
                                      )
                              ],
                            ),
                          ),
                        );
                      });
                });
            ;
          }),
    );
  }
}
