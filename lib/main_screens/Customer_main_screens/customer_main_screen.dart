import 'package:abn_realtors/main_screens/Customer_main_screens/profile_screen/profile_screen.dart';

import 'package:abn_realtors/settings/constants.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import '../../provider/auth_provider.dart';
import '../../provider/main_provider.dart';
import 'Home_screen/home_screen.dart';


class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({Key? key}) : super(key: key);

  static String id = 'customer_home';

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {

  var abn = Hive.box('abn');
  int _selectedIndex = 0;

  List<Widget> mainscreens=[
    HomeScreen(),
    Center(child: Text('Search Screen'),),
    Center(child: Text('Messages Screen'),),
   ProfileScreen()
  ];
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
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

        bottomNavigationBar: BottomBarDivider(

        items: const  [
          TabItem(
            icon: Icons.home,
            // title: 'Home',
          ),
          TabItem(
            icon: Icons.search_sharp,
            // title: 'Search',
          ),
          TabItem(
            icon: Icons.mail_outline_rounded,
            // title: 'Messaages',
          ),
          TabItem(
            icon: Icons.person_outline,
            // title: 'Profile',
          ),

        ],
        backgroundColor:listingprovider.getBackgroundColor(),
        color: listingprovider.lightMode? Color(0xFFB0B0B0) : listingprovider.getForegroundColor(),
        iconSize: 27,
        colorSelected: Constants.primaryColor,
        indexSelected: _selectedIndex,
        // paddingVertical: 24,
        onTap: (int index) => setState(() {
           _selectedIndex = index;
         }),
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //   backgroundColor:  listingprovider.getBackgroundColor(),
        //   elevation: 0,
        //   type: BottomNavigationBarType.fixed,
        //   selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        //   selectedItemColor: Constants.primaryColor,
        //   unselectedItemColor: listingprovider.lightMode? null : listingprovider.getForegroundColor(),
        //   currentIndex: _selectedIndex,
        //   items: [
        //     const BottomNavigationBarItem(
        //       icon: Icon(Icons.home_outlined),
        //       label: 'Home',
        //     ),
        //     const BottomNavigationBarItem(
        //       icon: Icon(Icons.search),
        //       label: 'Search',
        //     ),
        //
        //     BottomNavigationBarItem(
        //       icon: const Icon(Icons.mail_outline_rounded),
        //       label: 'Messages',
        //     ),
        //     const BottomNavigationBarItem(
        //       icon: Icon(Icons.person_outline_rounded),
        //       label: 'Profile',
        //     ),
        //   ],
        //   onTap: (index) {
        //     setState(() {
        //       _selectedIndex = index;
        //     });
        //   },
        // )

      ),
    );

  }
}
