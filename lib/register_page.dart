import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding/colors.dart';
import 'package:scaffolding/login_screen.dart';
import 'package:scaffolding/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordShown = true;
  bool isConfirmPasswordShown = true;
  PlatformFile? profilePic;
  UploadTask? uploadTask;

  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

// Method to launch the image picker
  Future pickImage() async {
    try {
      final pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
        allowMultiple: false,
      );
      if (pickedFile == null) return;

      setState(() {
        profilePic = pickedFile.files.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            "Error picking image",
            style: TextStyle(color: blackColor),
          ),
          elevation: 2,
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryColor,
          margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
        ),
      );
    }
  }

// Method to upload the profile image to Firebase Storage
  Future _uploadProfileImage() async {
    if (profilePic == null) {
      return ""; // Return an empty string if no image is selected
    }
    final path = 'profilePics/${profilePic!.name}';
    final file = File(profilePic!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      uploadTask = ref.putFile(file);
      final snapshot = await uploadTask!.whenComplete(() => {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      return urlDownload;
    } catch (e) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(color: textColor),
          ),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

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
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    _formKey.currentState!.save();
    if (_formData['password'] != _formData['cpassword']) {
      if (mounted) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Password and confirm password should be the same.',
                style: TextStyle(color: textColor),
              ),
              elevation: 2,
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryColor,
              margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
            ),
          );
        });
      }
    } else {
      try {
        // Upload the profile image to Firebase Storage
        String imageUrl = await _uploadProfileImage();
        if (imageUrl.isNotEmpty) {
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _formData['email'].toString().trim(),
            password: _formData['password'].toString().trim(),
          );
          // ignore: use_build_context_synchronously
          await sendEmailVerification(context);
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }

          if (userCredential.user != null) {
            final v = userCredential.user!.uid;
            DocumentReference<Map<String, dynamic>> db =
                FirebaseFirestore.instance.collection('users').doc(v);

            final user = UserModel(
              name: _formData['name'].toString(),
              id: v,
              email: _formData['email'].toString(),
              phone: _formData['phone'].toString(),
              work: _formData['work'].toString(),
              role: _formData['role'].toString(),
              profilePic: imageUrl,
            );
            final jsonData = user.toJson();
            await db.set(jsonData).whenComplete(() {
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => const LoginPage()));
            });
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }

            Fluttertoast.showToast(msg: 'Registration successful');
          }
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        } else {
          // Handle the case where the image upload fails
          if (mounted) {
            setState(() {
              isLoading = false;
              ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to upload profile image.',
                    style: TextStyle(color: textColor),
                  ),
                  elevation: 2,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: primaryColor,
                  margin:
                      const EdgeInsets.only(bottom: 25, left: 20, right: 20),
                ),
              );
            });
          }
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
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
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                    'Register',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: Container(
            //     width: 230,
            //     height: 230,
            //     margin: EdgeInsets.only(
            //       top: 70,
            //     ),
            //     decoration:
            //         BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            //   ),
            // ),
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
                          InkWell(
                            onTap: () async {
                              await pickImage();
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: profilePic != null
                                  ? CircleAvatar(
                                      radius: 60,
                                      backgroundImage:
                                          FileImage(File(profilePic!.path!)),
                                    )
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: textColor,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 15,
                                                spreadRadius: 2)
                                          ]),
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        color: primaryColor,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: blackColor),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                enableSuggestions: true,
                                style:
                                    TextStyle(fontSize: 16, color: blackColor),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                    hintText: 'Enter your name'),
                                validator: (name) {
                                  if (name!.isEmpty) {
                                    return "Please enter your name";
                                  }
                                  return null;
                                },
                                onSaved: (name) {
                                  _formData['name'] = name ?? "";
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
                                enableSuggestions: true,
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
                                'Phone',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: blackColor),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                enableSuggestions: true,
                                style:
                                    TextStyle(fontSize: 16, color: blackColor),
                                textCapitalization: TextCapitalization.none,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                    hintText: 'Enter your phone'),
                                validator: (phone) {
                                  if (phone!.isEmpty) {
                                    return "Please enter your phone number";
                                  } else if (phone.length != 10) {
                                    return "Enter a valid phone number";
                                  }
                                  return null;
                                },
                                onSaved: (phone) {
                                  _formData['phone'] = phone ?? "";
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
                                'Place of Work',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: blackColor),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                enableSuggestions: true,
                                style:
                                    TextStyle(fontSize: 16, color: blackColor),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                    hintText: 'Enter your place of working'),
                                validator: (work) {
                                  if (work!.isEmpty) {
                                    return "Please enter your place of work";
                                  }
                                  return null;
                                },
                                onSaved: (work) {
                                  _formData['work'] = work ?? "";
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
                                'Professional Role',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: blackColor),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                enableSuggestions: true,
                                style:
                                    TextStyle(fontSize: 16, color: blackColor),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                    hintText: 'Enter your professional role'),
                                validator: (role) {
                                  if (role!.isEmpty) {
                                    return "Please enter a role";
                                  }
                                  return null;
                                },
                                onSaved: (role) {
                                  _formData['role'] = role ?? "";
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

                          /// PASSWORD
                          ///
                          ///
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
                                enableSuggestions: true,
                                style:
                                    TextStyle(fontSize: 16, color: blackColor),
                                obscureText: isPasswordShown,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  suffixIcon: isPasswordShown
                                      ? IconButton(
                                          icon: const Icon(
                                              Icons.visibility_outlined),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordShown =
                                                  !isPasswordShown;
                                            });
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                              Icons.visibility_off_outlined),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordShown =
                                                  !isPasswordShown;
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
                            height: 30,
                          ),

                          ///
                          ///CONFIRM PASSWORD
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirm Password',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: blackColor),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                enableSuggestions: true,
                                style:
                                    TextStyle(fontSize: 16, color: blackColor),
                                obscureText: isConfirmPasswordShown,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  hintText: 'Re-enter your password',
                                  suffixIcon: isConfirmPasswordShown
                                      ? IconButton(
                                          icon: const Icon(
                                              Icons.visibility_outlined),
                                          onPressed: () {
                                            setState(() {
                                              isConfirmPasswordShown =
                                                  !isConfirmPasswordShown;
                                            });
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                              Icons.visibility_off_outlined),
                                          onPressed: () {
                                            setState(() {
                                              isConfirmPasswordShown =
                                                  !isConfirmPasswordShown;
                                            });
                                          },
                                        ),
                                ),
                                onSaved: (cpassword) {
                                  _formData['cpassword'] = cpassword ?? "";
                                },
                                validator: (cpassword) {
                                  if (cpassword!.isEmpty) {
                                    return "Please enter previous password";
                                  } else if (cpassword.length < 7) {
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
                                      'Register',
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
                                'Have an account? Login',
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
