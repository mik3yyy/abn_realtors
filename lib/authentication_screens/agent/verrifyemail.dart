import 'dart:async';

import 'package:abn_realtors/main_screens/Agents_main_screens/agents_main_screen.dart';
import 'package:abn_realtors/main_screens/Customer_main_screens/customer_main_screen.dart';
import 'package:abn_realtors/settings/messageHandler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../provider/main_provider.dart';
import '../../settings/constants.dart';
import 'Login.dart';


class VerifyAgentEmail extends StatefulWidget {
  const VerifyAgentEmail({Key? key}) : super(key: key);
  static String id = 'agent_verify_email';
  @override
  State<VerifyAgentEmail> createState() => _VerifyAgentEmailState();
}

class _VerifyAgentEmailState extends State<VerifyAgentEmail> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  bool isEmailVerified = false;
  Timer? timer ;
  bool canResendEmail = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {

      sendVerificationEmail();

     timer = Timer.periodic (
        Duration(seconds: 3),
          (_) => checkEmailVerified()
      );


    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {

    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail () async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });
    }  catch (e) {
      MyMessageHandler.showSnackBar(_scaffoldKey, e.toString());
    }
  }
  final abnBox = Hive.box('abn');



  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    return isEmailVerified ?
    AgentMainScreen()
        :
    ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: listingprovider.getBackgroundColor(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: listingprovider.getBackgroundColor(),
          title: Text('Verify Email',
            style: listingprovider.getTextStyle().copyWith(


          ),
          ),
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            height: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.mark_email_unread_outlined, color: Constants.primaryColor,size: 300,weight: 1,fill: 1,),
                Text('A verification email has not been sent to this email',

                style: TextStyle(
                  color: listingprovider.getForegroundColor()
                ),
                ),
                Text(authprovider.email,
                  style: TextStyle(
                    color: Constants.primaryColor
                  ),
                ),
                SizedBox(height: 10,),

                MaterialButton(
                  onPressed: canResendEmail? sendVerificationEmail : null,


                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    height: 50,
                    decoration:  BoxDecoration(
                        color: Constants.primaryColor,
                        border: Border.all(color: Constants.primaryColor),
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child:  Center(
                      child: Text("Resend Email",
                        style: TextStyle(
                            color: listingprovider.getForegroundColor(),
                            fontWeight: FontWeight.w700,
                            fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: MaterialButton(
                    onPressed: (){

                      Navigator.pop(context);




                    },
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      height: 50,
                      decoration:  BoxDecoration(
                          color: listingprovider.getBackgroundColor(),
                          border: Border.all(color: Constants.primaryColor),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child:  Center(
                        child: Text("Cancel",
                          style: TextStyle(
                              color: Constants.primaryColor,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ) ,
      ),
    );
  }
}
