import 'package:abn_realtors/authentication_screens/user/Login.dart';
import 'package:abn_realtors/authentication_screens/user/Sign_up.dart';
import 'package:abn_realtors/main_screens/Customer_main_screens/customer_main_screen.dart';
import 'package:abn_realtors/provider/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../settings/constants.dart';
import 'onboarding_text.dart';

class WelcomScreen extends StatefulWidget {
  const WelcomScreen({Key? key}) : super(key: key);
  static String id = "welcome_screen";
  @override
  State<WelcomScreen> createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> with SingleTickerProviderStateMixin {

  AnimationController? controller;
  Animation? Coloranimation;
  Animation? animation;
  final PageController _pageController = PageController();
  final PageController _pageController2 = PageController();

  int currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MainProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    return  Scaffold(
      // backgroundColor: Colors.white,
      body: Container(
       color: listingprovider.lightMode? listingprovider.getBackgroundColor(): Colors.black,

      height: MediaQuery.of(context).size.height,
        width:  MediaQuery.of(context).size.width,

        child: Column(

          children: [
            Container(
              height: MediaQuery.of(context).size.height *0.6,
              child: Stack(
                children: [
                  PageView(

                    children: [
                      Container(
                      height: MediaQuery.of(context).size.height *0.6,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/welcome_screen/House.png'),
                              fit: BoxFit.fill

                          )
                      ),

                    ),
                      Container(
                      height: MediaQuery.of(context).size.height *0.6,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/welcome_screen/House_2.png'),
                              fit: BoxFit.fill

                          )
                      ),

                    ),
                      Stack(
                        children: [
                          Container(
                          height: MediaQuery.of(context).size.height *0.6,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/welcome_screen/House_3.png'),
                                  fit: BoxFit.fill

                              )
                          ),

                    ),

                        ],
                      ),


                   ],
                    controller: _pageController,
                    onPageChanged: (int value){

                      setState(() {
                        currentPage = value;
                        _pageController2.animateToPage(currentPage, duration: Duration(milliseconds: 10), curve: Curves.linear);
                      });



                    },
                  ),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            color: listingprovider.lightMode? listingprovider.getBackgroundColor(): Colors.black,
                            borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          )
                        ),
                      )
                  )
                ],
              ),
            ),
            Container(
              // color: listingprovider.getBackgroundColor(),
              color: listingprovider.lightMode? listingprovider.getBackgroundColor(): Colors.black,

              height: 20,
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(

                    width: MediaQuery.of(context).size.width * 0.2,
                    // height: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          radius: currentPage ==0 ? 10: 5,
                          backgroundColor: currentPage == 0? Constants.primaryColor : Constants.greyColor,
                        ),
                        CircleAvatar(
                          radius: currentPage ==1 ? 10: 5,
                          backgroundColor: currentPage == 1? Constants.primaryColor : Constants.greyColor,
                        ),
                        CircleAvatar(
                          radius: currentPage ==2 ? 10: 5,
                          backgroundColor: currentPage == 2? Constants.primaryColor : Constants.greyColor,
                        ),


                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 20, right: 20, bottom:50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Expanded(

                        child: PageView(
                          controller: _pageController2,
                          onPageChanged: (int value){
                              print(currentPage);
                              print(value);

                            setState(() {
                              currentPage = value;
                              _pageController.animateToPage(currentPage, duration: Duration(milliseconds: 10), curve: Curves.linear);
                            });



                          },

                          children: [
                            OnboardingText(
                              listingprovider: listingprovider,
                              title: "We are your best Real Estate investments Partner.",
                              subtitle: "Our properties are just unique in every way possible. "
                                  "Ranging from good locations, Title, topography to even "
                                  "best prices. Lets take you on a tour, you will love it.",
                            ),
                            OnboardingText(
                              listingprovider: listingprovider,
                              title: "Welcome to our real estate app!.",
                              subtitle:"we're exicted to help you find your dream home. "
                                  " To get started, please create an account by entering your email address and choosing a secure password.",
                            ),
                            OnboardingText(
                                listingprovider: listingprovider,
                                title: "Let's Help you build that Property portfilo you desire.",
                                subtitle:"At ABN we are dedicated to provide you with affordable real estate investments with High ROI"

                            ),



                          ],
                        ),
                      ),
                      Container(height: 20,),

                    currentPage < 2 ?
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: (){

                                setState(() {
                                  currentPage = 2;
                                  _pageController.jumpToPage(currentPage);
                                  _pageController2.jumpToPage(currentPage);
                                  // print(currentPage);
                                  // _pageController.animateToPage(currentPage, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                  // _pageController2.animateToPage(currentPage, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                });
                              },
                              child: Text('skip',
                                style: TextStyle(
                                  color: listingprovider.getForegroundColor()
                                ),
                              )
                          ),

                          MaterialButton(
                              onPressed: (){

                                setState(() {
                                  currentPage++;
                                  _pageController.animateToPage(currentPage, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                  _pageController2.animateToPage(currentPage, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                });
                              },
                              padding: EdgeInsets.zero,
                              child: CircleAvatar(
                                backgroundColor: Constants.primaryColor,
                                radius:30,
                                child: Center(
                                  child: Text('Next',
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                ),),
                              )
                          )
                        ],
                      )
                      :
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: MaterialButton(
                                onPressed: (){
                                  Navigator.pushNamed(context, LoginScreen.id);

                                },
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 50,
                                  decoration:  BoxDecoration(
                                      color: listingprovider.getBackgroundColor(),
                                      border: Border.all(color: Constants.primaryColor),
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child:  Center(
                                    child: Text("Sign in",
                                      style: TextStyle(
                                          color: Constants.primaryColor,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MaterialButton(
                                onPressed: (){
                                  Navigator.pushNamed(context, SignUpScreen.id);
                                },
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                  height: 50,
                                  decoration:  BoxDecoration(
                                      color: Constants.primaryColor,
                                      border: Border.all(color: Constants.primaryColor),
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child:  Center(
                                    child: Text("Sign up",
                                      style: TextStyle(
                                        color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ),


                      ],
                    ),



                    ],
                  ),
                )
            )


          ],
        ),

      ),
    );
  }
}
