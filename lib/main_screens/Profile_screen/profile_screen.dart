import 'package:abn_realtors/authentication_screens/user/Login.dart';
import 'package:abn_realtors/main_screens/Profile_screen/Edit%20profile/edit_profile.dart';
import 'package:abn_realtors/main_screens/Profile_screen/saved_property/saved_property.dart';

import 'package:abn_realtors/settings/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../onboarding_screens/welcome_screen.dart';
import '../../provider/auth_provider.dart';
import '../../provider/main_provider.dart';
import '../../utils/bottom_sheet.dart';

import '../../utils/button_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var abn = Hive.box('abn');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // add your code here.

      if (authprovider.email.isEmpty) {
        Navigator.pushNamed(context, LoginScreen.id);
      }
    });

    return authprovider.email.isEmpty
        ? Container(
            color: listingprovider.getBackgroundColor(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty),
                Text("No Profile, Sign In?"),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: listingprovider.getBackgroundColor(),
                          border: Border.all(color: Constants.primaryColor),
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                              color: Constants.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Material(
            color: listingprovider.getBackgroundColor(),
            child: SafeArea(
              child: Scaffold(
                backgroundColor: listingprovider.getBackgroundColor(),
                body: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                authprovider.imageFile,
                                fit: BoxFit.fill,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
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
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          authprovider.fullname,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: listingprovider.getForegroundColor()),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ButtonTile(
                          listingprovider: listingprovider,
                          title: 'Edit Profile',
                          leading: Icon(
                            Icons.edit,
                            color: listingprovider.lightMode
                                ? null
                                : listingprovider.getForegroundColor(),
                          ),
                          traling: Icon(
                            Icons.chevron_right_outlined,
                            color: listingprovider.lightMode
                                ? null
                                : listingprovider.getForegroundColor(),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AgentEditProfile()));
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ButtonTile(
                          listingprovider: listingprovider,
                          title: 'Saved Properties',
                          leading: Icon(Icons.favorite_border,
                              color: listingprovider.lightMode
                                  ? null
                                  : listingprovider.getForegroundColor()),
                          traling: Icon(Icons.chevron_right_outlined,
                              color: listingprovider.lightMode
                                  ? null
                                  : listingprovider.getForegroundColor()),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SavedProperties()));
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ButtonTile(
                          listingprovider: listingprovider,
                          title: 'Notification',
                          leading: Icon(Icons.notifications_none,
                              color: listingprovider.lightMode
                                  ? null
                                  : listingprovider.getForegroundColor()),
                          traling: Icon(Icons.chevron_right_outlined,
                              color: listingprovider.lightMode
                                  ? null
                                  : listingprovider.getForegroundColor()),
                          onTap: () {},
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ButtonTile(
                          listingprovider: listingprovider,
                          title: 'Report an Agent',
                          leading: Icon(Icons.report,
                              color: listingprovider.lightMode
                                  ? null
                                  : listingprovider.getForegroundColor()),
                          traling: Icon(Icons.chevron_right_outlined,
                              color: listingprovider.lightMode
                                  ? null
                                  : listingprovider.getForegroundColor()),
                          onTap: () {},
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Constants.primaryColor)),
                          child: Center(
                            child: ListTile(
                                minVerticalPadding: 0.0,
                                leading: Icon(
                                  Icons.dark_mode,
                                  color: listingprovider.lightMode
                                      ? null
                                      : listingprovider.getForegroundColor(),
                                ),
                                title: Text(
                                  "Dark Mode",
                                  style: TextStyle(
                                      color:
                                          listingprovider.getForegroundColor()),
                                ),
                                trailing: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    listingprovider.changeBackgroundColor();
                                  },
                                  icon: listingprovider.lightMode
                                      ? Icon(
                                          FontAwesomeIcons.toggleOff,
                                          color: listingprovider.lightMode
                                              ? null
                                              : listingprovider
                                                  .getForegroundColor(),
                                        )
                                      : Icon(
                                          FontAwesomeIcons.toggleOn,
                                          color: listingprovider.lightMode
                                              ? null
                                              : listingprovider
                                                  .getForegroundColor(),
                                        ),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Constants.primaryColor),
                              color: Constants.primaryColor),
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.black38.withOpacity(0),
                                builder: (context) => CustomBottomSheet(
                                  title: 'Logout',
                                  description:
                                      'Are you sure you want to logout out?',
                                  tapNoText: 'Cancel',
                                  tapYesText: 'Yes,remove',
                                  noTap: () {
                                    Navigator.pop(context);
                                  },
                                  yesTap: () {
                                    FirebaseAuth.instance.signOut();
                                    authprovider.UserSignOut();
                                    abn.delete('user');
                                    Navigator.pushNamed(
                                        context, WelcomScreen.id);
                                  },
                                ),
                              );
                            },
                            child: const Center(
                              child: ListTile(
                                minVerticalPadding: 0.0,
                                leading: Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'Log Out',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
