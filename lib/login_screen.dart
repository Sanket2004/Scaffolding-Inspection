import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding/%E1%B8%A5ome_page.dart';
import 'package:scaffolding/colors.dart';
import 'package:scaffolding/forgot_password.dart';
import 'package:scaffolding/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordShown = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            "Email verification sent!",
            style: TextStyle(color: textColor),
          ),
          elevation: 2,
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryColor,
          margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            e.message.toString(),
            style: TextStyle(color: textColor),
          ),
          elevation: 2,
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryColor,
          margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
        ),
      );
    }
  }

  _onSubmit() async {
    setState(() {
      isLoading = true;
    });
    _formKey.currentState!.save();
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _formData['email'].toString().trim(),
        password: _formData['password'].toString().trim(),
      );
      setState(() {
        isLoading = false;
      });
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        if (userCredential.user != null) {
          Fluttertoast.showToast(msg: 'Login successful');
        }
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        await sendEmailVerification(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'No user found for provided email.',
                style: TextStyle(color: textColor),
              ),
              elevation: 2,
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryColor,
              margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Wrong password provided from that email.',
                style: TextStyle(color: textColor),
              ),
              elevation: 2,
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryColor,
              margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'The provided credential is invalid.',
                style: TextStyle(color: textColor),
              ),
              elevation: 2,
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryColor,
              margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
            ),
          );
        } else if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Email address is badly formated.',
                style: TextStyle(color: textColor),
              ),
              elevation: 2,
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryColor,
              margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
            ),
          );
        } else {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                e.toString(),
                style: TextStyle(color: textColor),
              ),
              elevation: 2,
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryColor,
              margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
            ),
          );
        }
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Positioned(
            bottom: MediaQuery.of(context).size.height / 4,
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25.0, right: 25, top: 5, bottom: 5),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 6,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: textColor,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: blackColor),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              style: TextStyle(fontSize: 16, color: blackColor),
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  hintText: 'Enter your email'),
                              validator: (email) {
                                if (email!.isEmpty) {
                                  return "Please enter a email";
                                } else if (email.length < 3 ||
                                    !email.contains('@')) {
                                  return "Enter a valid email";
                                } else if (!email.contains('.com')) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                              onSaved: (email) {
                                _formData['email'] = email ?? "";
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: blackColor),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              style: TextStyle(fontSize: 16, color: blackColor),
                              obscureText: isPasswordShown,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                suffixIcon: isPasswordShown
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.visibility_outlined),
                                        onPressed: () {
                                          setState(() {
                                            isPasswordShown = !isPasswordShown;
                                          });
                                        },
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                            Icons.visibility_off_outlined),
                                        onPressed: () {
                                          setState(() {
                                            isPasswordShown = !isPasswordShown;
                                          });
                                        },
                                      ),
                              ),
                              onSaved: (password) {
                                _formData['password'] = password ?? "";
                              },
                              validator: (password) {
                                if (password!.isEmpty) {
                                  return "Please enter a password";
                                } else if (password.length < 7) {
                                  return "Password length should be greater than 8";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordPage()));
                              },
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(500),
                          child: MaterialButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _onSubmit();
                              }
                            },
                            color: primaryColor,
                            minWidth: double.infinity,
                            height: 50,
                            child: isLoading
                                ? CupertinoActivityIndicator(
                                    color: textColor,
                                    animating: true,
                                    radius: 12,
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900),
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account yet? Register',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const RegisterPage()));
                              },
                              child: Text(
                                'here',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
