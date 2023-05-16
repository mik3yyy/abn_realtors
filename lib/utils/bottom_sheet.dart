import 'package:abn_realtors/onboarding_screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../provider/main_provider.dart';
import '../settings/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet(
      {Key? key,
      required this.title,
      required this.description,
      required this.noTap,
      required this.tapNoText,
      required this.tapYesText,
      required this.yesTap})
      : super(key: key);
  final String title;
  final String description;
  final String tapNoText;
  final String tapYesText;
  final Function() yesTap;
  final Function() noTap;

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  var abn = Hive.box('abn');

  bool processing = false;

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    return Container(
      height: 200,
      child: Scaffold(
        backgroundColor: listingprovider.lightMode
            ? Colors.black38.withOpacity(0)
            : Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: listingprovider.getBackgroundColor(),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0, bottom: 10),
                    child: SizedBox(
                      width: 70,
                      height: 10,
                      child: Divider(
                        thickness: 3,
                      ),
                    ),
                  ),
                  Text(
                    widget.title,
                    style: TextStyle(color: Color(0xFFFA4B4B)),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Divider(
                        thickness: 3,
                        color: listingprovider.lightMode
                            ? null
                            : listingprovider
                                .getForegroundColor()
                                .withOpacity(0.5),
                      )),
                  Text(widget.description,
                      style: TextStyle(
                          color: listingprovider.getForegroundColor())),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: MaterialButton(
                            onPressed: widget.noTap,
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: listingprovider.getBackgroundColor(),
                                  border:
                                      Border.all(color: Constants.primaryColor),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Stack(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      widget.tapNoText,
                                      style: TextStyle(
                                          color: Constants.primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  // Positioned(
                                  //   right: 10,
                                  //   top: 25/2,
                                  //   child: LoadingAnimationWidget.dotsTriangle(
                                  //     color: Constants.darkColor,
                                  //     // rightDotColor: Constant.generalColor,
                                  //     size: 20,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        )),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            onPressed: widget.yesTap,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Constants.primaryColor,
                                  border:
                                      Border.all(color: Constants.primaryColor),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Stack(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      widget.tapYesText,
                                      style: TextStyle(
                                          color: Constants.lightColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (listingprovider.bottomSheetYesProcessing)
                                    Positioned(
                                      right: 10,
                                      top: 25 / 2,
                                      child:
                                          LoadingAnimationWidget.dotsTriangle(
                                        color: Constants.darkColor,
                                        // rightDotColor: Constant.generalColor,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
