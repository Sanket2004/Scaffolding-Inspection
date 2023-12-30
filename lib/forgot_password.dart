import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scaffolding/colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool isPasswordShown = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _onSubmit() async {
    print(_formData['email'].toString().trim());

    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _formData['email'].toString().trim());
      // ignore: use_build_context_synchronously
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Sucess',
          ),
          content: Text(
            'Reset password link has been sent to your provided email.',
            textAlign: TextAlign.left,
            style: TextStyle(color: blackColor),
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(color: blackColor),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            )
          ],
        ),
      );
      setState(() {
        isLoading = false;
      });
      //Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
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
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If image is uploading, prevent back button action
        return !isLoading;
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.navigate_before,
              color: textColor,
            ),
          ),
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
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25, top: 5, bottom: 5),
                  child: Text(
                    'Forgot Password',
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
                                style:
                                    TextStyle(fontSize: 16, color: blackColor),
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
                              )
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
                                  _formKey.currentState!.save();
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
                                      'Reset',
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
                                'Have the password? Login',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
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
      ),
    );
  }
}
