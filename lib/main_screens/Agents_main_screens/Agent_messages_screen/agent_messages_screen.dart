import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_messages_screen/add_message_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';
import '../../../provider/messages_provider.dart';
import '../../../settings/constants.dart';
import '../../../utils/GridDummyScreen.dart';
import 'chart_screen.dart';

class AgentMessagesScreen extends StatefulWidget {
  const AgentMessagesScreen({Key? key}) : super(key: key);

  @override
  State<AgentMessagesScreen> createState() => _AgentMessagesScreenState();
}

class _AgentMessagesScreenState extends State<AgentMessagesScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  Stream<List<DocumentSnapshot<Object?>>>? mergedStream;

  void initState() {
    // TODO: implement initState
    super.initState();
    var messagesprovider =
        Provider.of<MessagesProvider>(context, listen: false);

    // StreamBuilder

    Stream<QuerySnapshot> _chatStream1 = chats
        .where("receiverid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    Stream<QuerySnapshot> _chatStream2 = chats
        .where("senderid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    List<String> users = [];
    mergedStream = Rx.combineLatest2(_chatStream1, _chatStream2,
        (QuerySnapshot query1, QuerySnapshot query2) {
      List<DocumentSnapshot> documents = [];

      for (int i = 0; i < query1.docs.length; i++) {
        String doc = query1.docs[i]["senderid"];
        if (users.contains(doc)) {
        } else {
          users.add(doc);
        }
      }

      for (int i = 0; i < query2.docs.length; i++) {
        var doc = query2.docs[i]["receiverid"];
        if (users.contains(doc)) {
        } else {
          users.add(doc);
        }
      }

      setState(() {
        messagesprovider.currentChat = users;
      });

      documents.addAll(query1.docs);
      documents.addAll(query2.docs);
      // documents = documents.shuffle()
      return documents;
    });
  }

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    var messagesprovider = Provider.of<MessagesProvider>(context, listen: true);

    print("hello");

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
      body: StreamBuilder<List<DocumentSnapshot>>(
          stream: mergedStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            print(messagesprovider.currentChat.length);
            return ListView.builder(
                itemCount: messagesprovider.currentChat.length,
                itemBuilder: (context, index) {
                  print("----------------");
                  Stream<QuerySnapshot> _agentStream = FirebaseFirestore
                      .instance
                      .collection('agents')
                      .snapshots();
                  Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
                      .collection('customers')
                      .snapshots();

                  final mergedStream2 =
                      Rx.combineLatest2(_agentStream, _userStream,
                          (QuerySnapshot query1, QuerySnapshot query2) {
                    // Combine the two query snapshots into a single list
                    List<DocumentSnapshot> documents = [];

                    print(query1.docs[0].id + "->");

                    for (int i = 0;
                        i < messagesprovider.currentChat.length;
                        i++) {
                      for (int j = 0; j < query1.docs.length; j++) {
                        if (messagesprovider.currentChat[i] ==
                            query1.docs[j].id) {
                          documents.add(query1.docs[i]);
                        }
                      }
                    }
                    for (int i = 0;
                        i < messagesprovider.currentChat.length;
                        i++) {
                      for (int j = 0; j < query2.docs.length; j++) {
                        if (messagesprovider.currentChat[i] ==
                            query2.docs[j].id) {
                          documents.add(query1.docs[i]);
                        }
                      }
                    }

                    return documents;
                  });

                  return StreamBuilder<List<DocumentSnapshot>>(
                    stream: mergedStream2,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return const Text(
                          'Something went wrong',
                          style: TextStyle(color: Colors.black),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return GridDummyScreen();
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
                      String letter1 = FirebaseAuth.instance.currentUser!.uid;

                      String letter2 = snapshot.data![index].id;
                      print("id2->" + letter2);

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

                      return ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                        user: snapshot.data![index],
                                      )));
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
                                snapshot.data![index]["image"],
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
                          snapshot.data![index]["fullname"],
                          style: TextStyle(
                              color: listingprovider.getForegroundColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        subtitle: Text(
                          snapshot.data![index]["email"],
                          style: TextStyle(
                              color: listingprovider.getForegroundColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      );
                    },
                  );
                });
          }),
    );
  }
}
