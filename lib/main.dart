import 'package:abn_realtors/authentication_screens/agent/Login.dart';
import 'package:abn_realtors/authentication_screens/agent/Sign_up.dart';
import 'package:abn_realtors/authentication_screens/agent/verrifyemail.dart';
import 'package:abn_realtors/authentication_screens/user/Login.dart';
import 'package:abn_realtors/authentication_screens/user/Sign_up.dart';
import 'package:abn_realtors/authentication_screens/user/verrifyemail.dart';
import 'package:abn_realtors/main_screens/Agents_main_screens/agents_main_screen.dart';
import 'package:abn_realtors/main_screens/Customer_main_screens/customer_main_screen.dart';
import 'package:abn_realtors/onboarding_screens/welcome_screen.dart';
import 'package:abn_realtors/provider/agent_provider/post_provider.dart';
import 'package:abn_realtors/provider/auth_provider.dart';
import 'package:abn_realtors/provider/favourite_provider.dart';
import 'package:abn_realtors/provider/main_provider.dart';
import 'package:abn_realtors/provider/messages_provider.dart';
import 'package:abn_realtors/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();

  var box = await Hive.openBox('abn');

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => MainProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => PostProvider()),
    ChangeNotifierProvider(create: (_) => MessagesProvider()),
    ChangeNotifierProvider(create: (_) => FavoriteProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  bool showSplash = true;

  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: listingprovider.getForegroundColor(),
            )),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(background: listingprovider.getBackgroundColor())),
      initialRoute: SplashScreen.id,
      routes: {
        WelcomScreen.id: (context) => const WelcomScreen(),
        SplashScreen.id: (context) => const SplashScreen(),
        //CUSTOMER
        LoginScreen.id: (context) => const LoginScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
        VerifyEmail.id: (context) => const VerifyEmail(),
        CustomerMainScreen.id: (context) => const CustomerMainScreen(),
        ////////AGENT
        AgentMainScreen.id: (context) => const AgentMainScreen(),
        AgentLoginScreen.id: (context) => const AgentLoginScreen(),
        AgentSignUp.id: (context) => const AgentSignUp(),
        VerifyAgentEmail.id: (context) => const VerifyAgentEmail(),
      },
    );
  }
}
