import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:scaffolding/%E1%B8%A5ome_page.dart';
import 'package:scaffolding/colors.dart';
import 'package:scaffolding/login_screen.dart';
import 'package:scaffolding/noInternet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: textColor),
  );
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool checkConnectivity = false;

  Future<bool> checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      print('YAY! Free cute dog pics!');
    } else {
      print('No internet :( Reason:');
      print(InternetConnectionChecker());
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    checkConnectivity = await checkConnection();
    setState(() {});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scaffolding Inspection Diary',
      theme: ThemeData(
        scaffoldBackgroundColor: textColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        // textTheme: GoogleFonts.cantarellTextTheme(
        //   Theme.of(context).textTheme,
        // ),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        // fontFamily: 'Text',
        useMaterial3: true,
      ),
      // home: StreamBuilder(
      //     stream: FirebaseAuth.instance.authStateChanges(),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasData) {
      //         return HomePage();
      //       } else {
      //         return LoginPage();
      //       }
      //     }),
      home: checkConnectivity
          ? FutureBuilder(
              future: Future.value(FirebaseAuth.instance.currentUser),
              builder: (context, AsyncSnapshot<User?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // If the Future is still running, show a loading indicator or splash screen.
                  return Scaffold(
                    appBar: null,
                    extendBodyBehindAppBar: true,
                    body: Center(
                      child: CupertinoActivityIndicator(
                        color: primaryColor,
                        animating: true,
                        radius: 18,
                      ),
                    ),
                  );
                } else {
                  // If the Future is complete, check for errors.
                  if (snapshot.hasError) {
                    // Handle errors by displaying an error message or taking appropriate action.
                    return SnackBar(
                      content: Text(
                        snapshot.error.toString(),
                        style: TextStyle(color: textColor),
                      ),
                      elevation: 2,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: primaryColor,
                      margin: const EdgeInsets.only(
                          bottom: 25, left: 20, right: 20),
                    );
                  } else if (snapshot.hasData) {
                    // User is logged in
                    User? user = snapshot.data;
                    if (user != null) {
                      if (user.emailVerified) {
                        // Existing user with verified email, show the home page
                        return const HomePage();
                      } else {
                        // Existing user with unverified email, show the login page
                        return const LoginPage();
                      }
                    } else {
                      // No user logged in, show the login page for new users
                      return const LoginPage();
                    }
                  } else {
                    // No user logged in, show the login page for new users
                    return const LoginPage();
                  }
                }
              },
            )
          : const NoInternetConnectionPage(),
    );
  }
}
