import 'dart:convert';

import 'package:abn_realtors/authentication_screens/agent/Login.dart';
import 'package:abn_realtors/authentication_screens/user/Sign_up.dart';
import 'package:abn_realtors/authentication_screens/user/verrifyemail.dart';
import 'package:abn_realtors/provider/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../provider/main_provider.dart';
import '../../settings/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../settings/messageHandler.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static String id = "login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();

  //firebase
  String _uid = '';
  CollectionReference customers =
  FirebaseFirestore.instance.collection('customers');

  var abn = Hive.box('abn');

  User ? user;
  bool invisible= true ;
  bool rememberme = true;
  bool processing = false;
  bool Gooogleprocessing = false;
  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    void Login()async{
      print("hello");
      if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          processing = true;
        });
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: authprovider.email, password: authprovider.password);
        String _uid = await FirebaseAuth.instance.currentUser!.uid;

        var user = await customers.doc(_uid).get();

        Map<String, dynamic> data =
        user.data() as Map<String, dynamic>;

        print(data);

        authprovider.fillData(data);
        // provider.getuser();

        print(authprovider.getuser());
        authprovider.rememberme = rememberme;
        if(rememberme){
          abn.put('user', authprovider.getuser());

        }
        setState(() {
          processing = false;
        });
        Navigator.pushNamed(context, VerifyEmail.id);


      } catch (e){
        setState(() {
          processing = false;
        });
        MyMessageHandler.showSnackBar(_scaffoldKey, "There seems to be an issue 😟");
        print(e.toString());
      }

      }else {
        MyMessageHandler.showSnackBar(_scaffoldKey, "There seems to be an issue 😟");
      }
    }


    Future<void> SignInWithGoogle() async{
      GoogleSignInAccount?  googleuser = await GoogleSignIn().signIn();

      GoogleSignInAuthentication? googleAuth = await googleuser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken

      );

      try {
        setState(() {
          Gooogleprocessing = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);


        user = userCredential.user;





        print('hello');







      } on FirebaseAuthException catch (e) {
        setState(() {
          Gooogleprocessing = false;
        });
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
          print('invalid 1');

        }
        else if (e.code == 'invalid-credential') {
          // handle the error here
          print('invalid 2');
        }
        print(e.toString());

      } catch (e) {
        setState(() {
          Gooogleprocessing = false;
        });
        // handle the error here
      }
    }

    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: listingprovider.getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: listingprovider.getBackgroundColor(),
          elevation: 0,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.chevron_left, color: listingprovider.getForegroundColor(),),
            
          ),
          title:  Image.asset('assets/images/abn_logo.png'),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
          color: listingprovider.getBackgroundColor(),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 15.0, top:0),
                //   child: Image.asset('assets/images/abn_logo.png'),
                // ),

                Text('Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: listingprovider.getForegroundColor(),
                    fontSize: 24
                  ),

                ),
                Text('We\'re so happy to see you back again!',
                  style: TextStyle(
                    color: listingprovider.getForegroundColor(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height *0.8,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('E-mail',
                            style: TextStyle(
                              color: listingprovider.getForegroundColor(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5,bottom: 15),
                            child: TextFormField(
                              validator: (String? value){
                                if (value!.isEmpty){
                                  return 'what is your email';
                                }
                                return null;
                              },
                                onChanged: (String ? value){
                                authprovider.email = value!;
                                },
                                style: TextStyle(
                                  color: listingprovider.getForegroundColor()
                                ),
                              keyboardType: TextInputType.emailAddress,

                              decoration: Constants.textFormDecoration.copyWith(
                                prefixIcon: Icon(Icons.email_outlined),


                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                    borderRadius: BorderRadius.circular(20),

                              ),


                              )
                            ),
                          ),
                          Text('Password',
                          style: TextStyle(
                            color: listingprovider.getForegroundColor()
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0, bottom: 15),
                            child: TextFormField(
                              validator: (String? value){
                                if (value!.isEmpty){
                                  return 'what is your password';
                                }
                                return null;
                              },
                              onChanged: (String ? value){
                                authprovider.password = value!;
                              },
                              style: TextStyle(
                                  color: listingprovider.getForegroundColor()
                              ),
                              obscureText: invisible,
                                decoration: Constants.textFormDecoration.copyWith(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                      onPressed: (){
                                        setState(() {
                                          invisible = !invisible;
                                        });
                                      },
                                      icon: invisible? Icon(Icons.visibility):Icon(Icons.visibility_off)
                                  ),
                                  hintText: '********',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color:  listingprovider.getForegroundColor(),)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                    borderRadius: BorderRadius.circular(20),

                                  ),

                                ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Row(
                                children: [
                                  Checkbox(

                                      value: rememberme,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (value){
                                        setState(() {

                                        rememberme = !rememberme;
                                        });
                                      },
                                      fillColor: MaterialStateProperty.all(Constants.primaryColor),

                                  ),
                                  Text('Remember me ',
                                    style: TextStyle(
                                        color: Colors.grey
                                    ),

                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: (){},
                                child: Text('Forgotten password',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Opacity(
                            // duration: Duration(seconds: 1),
                            opacity: processing? 0.5 : 1,
                            child: MaterialButton(
                              onPressed: (){
                                Login();

                              },
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                height: 50,
                                decoration:  BoxDecoration(

                                    color: Constants.primaryColor,
                                    border: Border.all(color: Constants.primaryColor),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Text("Login",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16
                                        ),
                                      ),
                                    ),
                                    if(processing)
                                      Positioned(
                                        right: 10,
                                        top: 25/2,
                                        child: LoadingAnimationWidget.hexagonDots(
                                          color: listingprovider.getBackgroundColor(),
                                          // rightDotColor: Constant.generalColor,
                                          size: 20,
                                        ),
                                      ),


                                  ],
                                )




                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(child: Divider(thickness: 2, height: 20, color: listingprovider.getForegroundColor(),)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                                child: Text('Or Login with',
                                  style: TextStyle(
                                    color: listingprovider.getForegroundColor()
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(thickness: 2, height: 20,color: listingprovider.getForegroundColor(),))
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child:Opacity(
                                      // duration: Duration(seconds: 1),
                                      opacity: Gooogleprocessing? 0.5 : 1,
                                      child: MaterialButton(
                                        onPressed:Gooogleprocessing? null :() async {

                                        await  SignInWithGoogle().then((value) async {
                                          try {
                                            setState(() {
                                              Gooogleprocessing = true;
                                            });
                                            print("1");
                                            authprovider.email = user!.email!;

                                            authprovider.fullname =
                                            user!.displayName!;
                                            authprovider.phonenumber =
                                            user?.phoneNumber == null
                                                ? ''
                                                : user!.phoneNumber!;
                                            print("2");


                                            String _uid = await FirebaseAuth
                                                .instance.currentUser!.uid;
                                            print("3");

                                            var customer = await customers.doc(
                                                _uid).get();
                                            print("4");

                                            Map<String, dynamic> data =
                                            customer.data() as Map<
                                                String,
                                                dynamic>;

                                            print(customer.data());

                                            authprovider.fillData(data);

                                            print(authprovider.getuser());
                                            authprovider.rememberme =
                                                rememberme;
                                            if (rememberme) {
                                              abn.put('user',
                                                  authprovider.getuser());
                                            }
                                            setState(() {
                                              Gooogleprocessing = false;
                                            });
                                            Navigator.pushNamed(
                                                context, VerifyEmail.id);
                                          } catch(e){
                                            print(e.toString());
                                            setState(() {
                                              Gooogleprocessing = false;
                                            });
                                            MyMessageHandler.showSnackBar(_scaffoldKey, "User Doesn't exits");
                                          }

                                        });






                                        },
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 50,
                                          decoration:  BoxDecoration(
                                              color: listingprovider.getBackgroundColor(),
                                              border: Border.all(color: Constants.primaryColor),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child:  Stack(
                                            children:[
                                              Center(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(FontAwesomeIcons.google , color: Constants.primaryColor,),
                                                  Text(" Google",
                                                    style: TextStyle(
                                                        color: listingprovider.getForegroundColor(),
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                              if(Gooogleprocessing)
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: LoadingAnimationWidget.hexagonDots(
                                                  color: listingprovider.getForegroundColor(),
                                                  // rightDotColor: Constant.generalColor,
                                                  size: 20,
                                                ),
                                              ),
                                          ]
                                          ),

                                        ),
                                      ),
                                    ),
                                  )
                              ),



                            ],
                          ),
                          Center(
                            child: TextButton(
                                onPressed: (){
                                  Navigator.pushReplacementNamed(context, AgentLoginScreen.id);

                                },

                                child: Text('Login as an agent?'),
                            ),),
                          Container(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Don\'t have an account?',
                                  style: TextStyle(color: listingprovider.getForegroundColor()) ,
                                ),
                                TextButton(
                                    onPressed: (){
                                  Navigator.pushReplacementNamed(context, SignUpScreen.id);
                                }, child: Text('Sign up?'))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
