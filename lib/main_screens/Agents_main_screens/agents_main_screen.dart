import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_AddProperties_Screen/add_property_screen.dart';
import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_Home_Screen/agent_home_screen.dart';
import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_Search_Screen/agent_search_screen.dart';
import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_messages_screen/agent_messages_screen.dart';
import 'package:abn_realtors/main_screens/Agents_main_screens/Agent_profile_screen/agent_profile_screen.dart';
import 'package:abn_realtors/main_screens/Customer_main_screens/profile_screen/profile_screen.dart';
import 'package:abn_realtors/settings/constants.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import '../../provider/auth_provider.dart';
import '../../provider/main_provider.dart';
import '../../provider/messages_provider.dart';
import '../Customer_main_screens/Home_screen/home_screen.dart';
import 'Agent_messages_screen/add_message_screen.dart';



////////////////////////




class AgentMainScreen extends StatefulWidget {
  const AgentMainScreen({Key? key}) : super(key: key);

  static String id = 'agent_home';

  @override
  State<AgentMainScreen> createState() => _AgentMainScreenState();
}

class _AgentMainScreenState extends State<AgentMainScreen> {


  var abn = Hive.box('abn');
  int _selectedIndex = 0;



  List<Widget> mainscreens=[

    AgentHomeScreen(),
    AgentSearchScreen(),

    AgentMessagesScreen(),
   AgentProfileScreen()
  ];
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  CollectionReference chats =
  FirebaseFirestore.instance.collection('chats');
  @override
  Widget build(BuildContext context) {

    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);


    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(

        backgroundColor: listingprovider.getBackgroundColor(),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: mainscreens[_selectedIndex],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Constants.primaryColor,
          onPressed: () {
            showModalBottomSheet(

              enableDrag:  false,

              context: context,
              backgroundColor:  Colors.black38.withOpacity(0),
              isScrollControlled: true,
              builder: (context) =>AddProperty(),
            );

          },
          child: Center(
            child: Icon(Icons.add),
          ),
          //params
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar(

          icons: [
           _selectedIndex==0?  Icons.home:Icons.home_outlined,
            _selectedIndex==1?  Icons.search_sharp: Icons.search_sharp,
            _selectedIndex==2?    Icons.mail: Icons.mail_outline_rounded,
            _selectedIndex==3?  Icons.person: Icons.person_outline,
          ],
          activeColor: Constants.primaryColor,
          inactiveColor: Colors.grey,
          backgroundColor: listingprovider.getBackgroundColor(),



          activeIndex: _selectedIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          onTap: (index) => setState(() => _selectedIndex = index),

          //other params
        ),
        // bottomNavigationBar: BottomBarDivider(
        //
        // items: const  [
        //   TabItem(
        //     icon: Icons.home,
        //     // title: 'Home',
        //   ),
        //   TabItem(
        //     icon: Icons.search_sharp,
        //     // title: 'Search',
        //   ),
        //    TabItem(
        //     icon:CupertinoIcons.add_circled,
        //     // title: 'Search',
        //   ),
        //
        //   TabItem(
        //     icon: Icons.mail_outline_rounded,
        //     // title: 'Messaages',
        //   ),
        //   TabItem(
        //     icon: Icons.person_outline,
        //     // title: 'Profile',
        //   ),
        //
        // ],
        // backgroundColor:listingprovider.getBackgroundColor(),
        // color: listingprovider.lightMode? Color(0xFFB0B0B0) : listingprovider.getForegroundColor(),
        //
        // colorSelected: Constants.primaryColor,
        // indexSelected: _selectedIndex,
        // iconSize: 27,
        // // paddingVertical: 24,
        // onTap: (int index) => setState(() {
        //    _selectedIndex = index;
        //  }),
        // ),


      ),
    );

  }
}
