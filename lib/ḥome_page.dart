import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding/add_inspection.dart';
import 'package:scaffolding/colors.dart';
import 'package:scaffolding/login_screen.dart';
import 'package:scaffolding/view_inspection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? auth = FirebaseAuth.instance.currentUser;

  Future<void> deleteInspection(String id) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("inspections")
        .doc(id)
        .delete();
  }

  void deleteDialog(String title, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            "Warning",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "$title - will be deleted.",
            style: TextStyle(color: blackColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    deleteInspection(id);
                    Navigator.of(context).pop(); // Close the dialog
                  });
                }
              },
              child: Text(
                'Ok',
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          backgroundColor: textColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const AddInspectionPage()));
          },
          backgroundColor: primaryColor,
          elevation: 0,
          hoverElevation: 0,
          focusElevation: 0,
          highlightElevation: 0,
          child: Icon(
            Icons.post_add_outlined,
            color: textColor,
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          actions: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                onPressed: () async {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.logout_outlined,
                  color: textColor,
                  size: 20,
                ),
              ),
            ),
          ],
          title: Text(
            'All Inspections',
            style: TextStyle(
                fontSize: 20, color: textColor, fontWeight: FontWeight.w900),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(0))),
          backgroundColor: primaryColor,
        ),
        body: SafeArea(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('inspections')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Center(
                    child: CircularProgressIndicator(),
                  ));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading inspections',
                      style: TextStyle(
                          fontSize: 16,
                          color: blackColor,
                          fontWeight: FontWeight.w900),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No inspections available',
                      style: TextStyle(
                          fontSize: 16,
                          color: blackColor,
                          fontWeight: FontWeight.w900),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final QueryDocumentSnapshot<Object?> document =
                        snapshot.data!.docs[index];

                    final Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return Dismissible(
                      key: Key(document.id),
                      onDismissed: (direction) {
                        setState(() {
                          deleteDialog(data['title'], document.id);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 12.0, left: 12, right: 12),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ViewInspectionPage(
                                  data: data,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Container(
                                    width: double.infinity,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: data['inspectionImage'] != null
                                            ? Image.network(
                                                data['inspectionImage'],
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child; // Image is fully loaded, display it.
                                                  } else {
                                                    return Center(
                                                      child: Container(
                                                        width: 80,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                                'Loading'),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            LinearProgressIndicator(
                                                              minHeight: 5,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      (loadingProgress
                                                                              .expectedTotalBytes ??
                                                                          1)
                                                                  : null,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              )
                                            : const Text('Loading')),
                                  ),
                                ),
                                Positioned(
                                  top: 190,
                                  bottom: 0,
                                  left: -0.1,
                                  right: 0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: textColor,
                                        border: Border.all(
                                            color:
                                                primaryColor.withOpacity(0.3),
                                            width: 5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            data['title'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: blackColor,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            data['location'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: blackColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('yyyy-MM-dd').format(
                                                data['inspectionDate']
                                                    .toDate()),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: blackColor,
                                              fontWeight: FontWeight.w500,
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
                  },
                );
              }),
        ),
      ),
    );
  }
}
