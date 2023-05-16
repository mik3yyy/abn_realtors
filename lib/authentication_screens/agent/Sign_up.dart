import 'package:abn_realtors/authentication_screens/agent/Login.dart';
import 'package:abn_realtors/authentication_screens/agent/fill_profile.dart';
import 'package:abn_realtors/authentication_screens/user/Login.dart';
import 'package:abn_realtors/authentication_screens/user/Sign_up.dart';
import 'package:abn_realtors/authentication_screens/user/fill_profile.dart';
import 'package:abn_realtors/provider/auth_provider.dart';
import 'package:abn_realtors/settings/messageHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../provider/main_provider.dart';
import '../../settings/constants.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
class AgentSignUp extends StatefulWidget {
  const AgentSignUp({Key? key}) : super(key: key);
  static String id = "agent_signup_screen";
  @override
  State<AgentSignUp> createState() => _AgentSignUpState();
}

class _AgentSignUpState extends State<AgentSignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();

  final TextEditingController controller =  TextEditingController();

  ///Passing a key to access the validate function
  final GlobalKey<FlutterPwValidatorState> validatorKey = GlobalKey<FlutterPwValidatorState>();



  // String password= '';
  // String email= '';
  bool passwordVisible = true ;
  bool comfirmPasswordVisible = true;

  bool passwordvalidated  = false ;

  bool agreedterms = false ;
  User ? user;
  CollectionReference customers =
  FirebaseFirestore.instance.collection('agents');
  CollectionReference customers2 =
  FirebaseFirestore.instance.collection('customers');
  bool Googleprocessing = false;

  void SignUp (){


    if (_formKey.currentState!.validate()) {
      if (agreedterms){
        Navigator.push(context,MaterialPageRoute(builder: (context)=>const FillAgentProfile()) );

      } else {
        MyMessageHandler.showSnackBar(_scaffoldKey, "You didn't agree to our terms and conditions 🥺");

      }

    } else {
      MyMessageHandler.showSnackBar(_scaffoldKey, "There seems to be an issue 😟");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.text = Provider.of<AuthProvider>(context, listen: false).password;
  }


  @override
  Widget build(BuildContext context) {



    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
   Future<void> SignInWithGoogle() async{
      GoogleSignInAccount?  googleuser = await GoogleSignIn().signIn();

      GoogleSignInAuthentication? googleAuth = await googleuser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken

      );

      try {
        setState(() {
          Googleprocessing = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);


        user = userCredential.user;
        var userexist = await customers.doc(user!.uid).get();
        var userexist2 = await customers.doc(user!.uid).get();

        print(userexist.exists);

        if(userexist.exists || userexist2.exists){
          setState(() {
            Googleprocessing = false;
          });
          MyMessageHandler.showSnackBar(_scaffoldKey, 'This User Already Exists, Login?');
        } else if(user!=null){
          setState(() {
            Googleprocessing = false;
          });

          print(user!.email);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>FillAgentProfile()));

          authprovider.email= user!.email!;

          authprovider.fullname= user!.displayName!;
          authprovider.phonenumber= user!.phoneNumber!;
          print(authprovider.user);
        }
        setState(() {
          Googleprocessing = false;
        });






      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
          print('invalid 1');
          setState(() {
            Googleprocessing = false;
          });
          MyMessageHandler.showSnackBar(_scaffoldKey, 'account exists with different credential');

        }
        else if (e.code == 'invalid-credential') {
          // handle the error here
          MyMessageHandler.showSnackBar(_scaffoldKey, 'invalid-credential');

        }
        MyMessageHandler.showSnackBar(_scaffoldKey, 'Error validating');

        print(e.toString());

      } catch (e) {
        MyMessageHandler.showSnackBar(_scaffoldKey, 'Error, Check your network');

        // handle the error here
      }
    }



    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: listingprovider.getBackgroundColor(),
          elevation:  0,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.chevron_left, color: listingprovider.getForegroundColor(),),

          ),
          title: Image.asset('assets/images/abn_logo.png'),
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
                //   padding: const EdgeInsets.only(bottom: 15.0, top: 0),
                //   child: Image.asset('assets/images/abn_logo.png'),
                // ),

                Text('Sign up',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    color: listingprovider.getForegroundColor()
                  ),

                ),
                Text('Create an agent account with ease',
                  style: TextStyle(
                    color: listingprovider.getForegroundColor()
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 1.2,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          Text('E-mail',
                            style: TextStyle(
                              color: listingprovider.getForegroundColor()
                            ),

                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5,bottom: 15),
                            child: TextFormField(
                              initialValue: authprovider.email,
                              validator: (String? value ){
                                if (value!.isEmpty){

                                  return 'please enter your email';

                                } else if ( !value.isValidEmail() ){
                                  return 'enter a valid email';
                                } else {
                                  return null;
                                }
                              },
                                onChanged: (String? value){
                                authprovider.email = value!;
                                },
                                style: TextStyle(
                                  color: listingprovider.getForegroundColor()
                                ),
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
                              controller: controller,
                                // initialValue: authprovider.password,
                                obscureText: passwordVisible,
                                onChanged: (String? value){
                                  authprovider.password = value!;
                                },
                                style: TextStyle(
                                    color: listingprovider.getForegroundColor(),
                                ),
                                validator: (String? value ){
                                  if (value!.isEmpty){

                                    return 'please enter your password';
                                  } else if (value.length < 6){
                                    return 'Weak password, add more characters';
                                  } else if (passwordvalidated == false ){
                                    return 'Input a strong password';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: Constants.textFormDecoration.copyWith(
                                    prefixIcon: Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            passwordVisible = !passwordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,

                                        )),
                                    hintText: '********',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:  listingprovider.getForegroundColor(),),
                                    borderRadius: BorderRadius.circular(20),

                                  ),
                                )
                            ),
                          ),
                          FlutterPwValidator(
                            key: validatorKey,
                            controller: controller,
                            minLength: 8,
                            uppercaseCharCount: 2,
                            numericCharCount: 1,
                            specialCharCount: 1,
                            normalCharCount: 3,
                            width: 400,
                            height: 136,
                            defaultColor: Constants.greyColor,
                            successColor: Constants.primaryColor,
                            failureColor: Constants.greyColor,
                            onSuccess: () {
                              print("MATCHED");
                              setState(() {
                                passwordvalidated = true;
                              });
                            },
                            onFail: () {
                              print("NOT MATCHED");
                              setState(() {
                                passwordvalidated = false;
                              });
                            },
                          ),


                          Row(
                            children: [
                              Checkbox(

                                value: agreedterms,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onChanged: (value){

                                  setState(() {
                                    agreedterms = !agreedterms;
                                  });
                                },
                                fillColor: MaterialStateProperty.all(Constants.primaryColor),

                              ),
                              Text('I agree to the',
                                style: TextStyle(
                                    color: Colors.grey
                                ),

                              ),
                              TextButton(
                                  onPressed: (){},
                                  child: Text('Terms and Conditions')
                              )
                            ],
                          ),

                          MaterialButton(
                            onPressed: (){

                              SignUp();






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
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 25,
                            child: Row(
                              children: [
                                Expanded(child: Divider(thickness: 2, height: 20,color: Colors.grey.shade300,)),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Or Login with', style: TextStyle(color: Colors.grey.shade300),),
                                ),

                                Expanded(child: Divider(thickness: 2, height: 20,color:Colors.grey.shade300,))
                              ],
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Opacity(
                                      opacity: Googleprocessing? 0.5 : 1,
                                      child: MaterialButton(
                                        onPressed: ()async{

                                         await SignInWithGoogle().then((value) {



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
                                          child:    Stack(
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
                                                if(Googleprocessing)
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

                          Container(
                            height: 34,
                            child: Center(
                              child: TextButton(
                                onPressed: (){
                                  Navigator.pushNamed(context, SignUpScreen.id);
                                },
                                child: Text('Sign up as a user?'),
                              ),),
                          ),
                          Container(
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account?',
                                  style: TextStyle(
                                    color: listingprovider.getForegroundColor()
                                  ),
                                ),
                                TextButton(onPressed: (){
                                  Navigator.pushReplacementNamed(context, AgentLoginScreen.id);
                                }, child: Text('Login?'))
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
// extension EmailValidator on String {
//   bool isValidEmail() {
//     return RegExp(
//         r'^([a-zA-Z0-9]+)([\-\_\.]*)([a-zA-Z0-9]*)([@])([a-zA-Z0-9]{2,})([\.][a-zA-Z]{2,3})$')
//         .hasMatch(this);
//   }
// }
