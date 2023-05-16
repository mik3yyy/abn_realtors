import 'package:abn_realtors/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:zwidget/zwidget.dart';
import 'dart:math';
import 'main_screens/Agents_main_screens/agents_main_screen.dart';
import 'main_screens/Customer_main_screens/customer_main_screen.dart';
import 'onboarding_screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
 static String id = "splash_sceer";
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with
    SingleTickerProviderStateMixin{
  AnimationController ?controller;
  Animation ?rotationX;
  Animation ?rotationY;
  bool hidden = true;
  @override
  void initState() {
    super.initState();

    controller =  AnimationController(vsync: this, duration: Duration(seconds: 3));

    rotationX = Tween<double>(begin: pi / 3, end: 0.0).animate(controller!);
    rotationY = Tween<double>(begin:  -pi / 4, end: 0.0).animate(controller!);

    controller!.forward();
    controller!.addStatusListener((status) {});
    controller!.addListener(() {

      setState(() {});
    });
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    Future.delayed(Duration(seconds: 5), (){
      initPrefs(context);
    }). then((value) {

      Navigator.pushReplacementNamed(context, authprovider.email.isNotEmpty? authprovider.agent?AgentMainScreen.id :  CustomerMainScreen.id : WelcomScreen.id,);
    });
  }

  initPrefs(BuildContext context ) async {

    var authprovider = Provider.of<AuthProvider>(context, listen: false);

    var box = Hive.box('abn');

    if(box.get('user')  != null){
      print(box.get('user').toString());
      authprovider.fillData(box.get('user') );

    }




  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,

      body: Container(


          decoration: BoxDecoration(
            gradient: LinearGradient(

              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.0, 1.0],
              colors: [

                Color(0xFF1B4A69),
                Color(0xFF3593D1),

              ],
            ),

          ),
          child:  Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: Duration(seconds: 1),
                  child: Image(
                    image: AssetImage("assets/images/splash_bg.png", ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),


              Center(
                child: ZWidget.forwards(
                  rotationX: rotationX!.value,
                  rotationY: rotationY!.value,
                  layers: 12,
                  depth: 12,
                  midChild:Container(
                    height: 70,
                    width: 300,
                    child:  Image.asset("assets/images/abn_logo.png", fit: BoxFit.fill,)
                  )
                ),
              ),
            ],
          )
      ),
    );
  }
}
