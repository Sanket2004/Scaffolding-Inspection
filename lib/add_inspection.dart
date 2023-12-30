import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding/colors.dart';

class AddInspectionPage extends StatefulWidget {
  const AddInspectionPage({super.key});

  @override
  State<AddInspectionPage> createState() => _AddInspectionPageState();
}

class _AddInspectionPageState extends State<AddInspectionPage> {
  DateTime? inspectionDate;
  DateTime? tagReInspectionDate;
  DateTime? tagRemoveDate;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  List<String> duties = [
    'Light Duty',
    'General Duty',
    'Heavy Duty',
    'Special Duty'
  ];
  late String selectedDuty; // Declare as late so that it can be assigned later.

  List<String> scaffold = [
    'Static Scaffold',
    'Independent Tower',
    'Bird Cage Tower',
    'Cantiliver Tower',
    'Mobile Tower',
    'Hanging Tower',
    'Suspended Tower',
  ];
  late String
      selectedScaffold; // Declare as late so that it can be assigned later.

  List<String> data = [
    "Sole Board",
    "Sole Plate",
    "Screw Base Jack",
    "Base Plate",
    "Standard Pipe",
    "Ledger Pipe",
    "Transom Pipe",
    "Brace Pipe",
    "Platform Board",
    "Guardrails",
    "Toe Board",
    "Tie Support",
    "Access"
  ];
  List<String> userChecked = [];

  void _onSelected(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userChecked.add(dataName);
      });
    } else {
      setState(() {
        userChecked.remove(dataName);
      });
    }
  }

  PlatformFile? inspectionImage;
  UploadTask? uploadTask;

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
        inspectionImage = pickedFile.files.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error picking image",
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

  // Method to upload the image to Firebase Storage
  Future _uploadInspectionImage() async {
    if (inspectionImage == null) {
      return ""; // Return an empty string if no image is selected
    }
    final path = 'inspectionImages/${inspectionImage!.name}';
    final file = File(inspectionImage!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      uploadTask = ref.putFile(file);
      final snapshot = await uploadTask!.whenComplete(() => {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      return urlDownload;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  void initState() {
    super.initState();
    // Initialize 'selectedDuty' here with a valid value from 'duties'.
    selectedDuty = duties.isNotEmpty ? duties[0] : '';
    selectedScaffold = scaffold.isNotEmpty ? scaffold[0] : '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != inspectionDate) {
      setState(() {
        inspectionDate = picked;
      });
    }
  }

  Future<void> _selectReInspectionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != tagReInspectionDate) {
      setState(() {
        tagReInspectionDate = picked;
      });
    }
  }

  Future<void> _selectTagremoveDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != tagRemoveDate) {
      setState(() {
        tagRemoveDate = picked;
      });
    }
  }

  final CollectionReference _inspectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('inspections');

  addData() async {
    setState(() {
      isLoading = true;
    });
    _formKey.currentState!.save();
    if (inspectionDate == null) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select inspection date',
              style: TextStyle(color: textColor),
            ),
            elevation: 2,
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor,
            margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
          ),
        );
      });
    } else if (tagReInspectionDate == null) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select tag re-inspection date',
              style: TextStyle(color: textColor),
            ),
            elevation: 2,
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor,
            margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
          ),
        );
      });
    } else if (tagRemoveDate == null) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select tag remove date',
              style: TextStyle(color: textColor),
            ),
            elevation: 2,
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor,
            margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
          ),
        );
      });
    } else if (selectedDuty.isEmpty) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select the duty of scaffold',
              style: TextStyle(color: textColor),
            ),
            elevation: 2,
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor,
            margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
          ),
        );
      });
    } else if (selectedScaffold.isEmpty) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select the type of scaffold',
              style: TextStyle(color: textColor),
            ),
            elevation: 2,
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor,
            margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
          ),
        );
      });
    } else if (userChecked.isEmpty) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select scaffold hand safety checklist',
              style: TextStyle(color: textColor),
            ),
            elevation: 2,
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor,
            margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
          ),
        );
      });
    } else {
      try {
        String imageUrl = await _uploadInspectionImage();
        if (imageUrl.isNotEmpty) {
          await _inspectionRef.add({
            'title': _formData['title'],
            'location': _formData['location'],
            'clientName': _formData['clientName'],
            'inspectionDate': inspectionDate,
            'dutyOfScaffold': selectedDuty,
            'scaffoldLength': _formData['length'],
            'scaffoldWidth': _formData['width'],
            'scaffoldHeight': _formData['height'],
            'scaffoldVolume': _formData['volume'],
            'scaffoldType': selectedScaffold,
            'tagReInspectionDate': tagReInspectionDate,
            'tagRemoveDate': tagRemoveDate,
            'handSafetyChecklist': userChecked,
            'inspectedBy': _formData['inspector'],
            'inspectionImage': imageUrl,
          });
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Inspection added');
          Navigator.pop(context);
        } else {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to upload profile image.',
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
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
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
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.navigate_before,
              color: textColor,
            ),
          ),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.all(5.0),
          //     child: IconButton(
          //       onPressed: () async {},
          //       icon: Icon(
          //         Icons.logout_outlined,
          //         color: textColor,
          //         size: 20,
          //       ),
          //     ),
          //   ),
          // ],
          title: Text(
            'Add Inspections',
            style: TextStyle(
                fontSize: 20, color: textColor, fontWeight: FontWeight.w900),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(0))),
          backgroundColor: primaryColor,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title of scaffolding',
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
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            hintText: 'Enter the title of scaffolding'),
                        validator: (title) {
                          if (title!.isEmpty) {
                            return "Please enter a title";
                          }
                          return null;
                        },
                        onSaved: (title) {
                          _formData['title'] = title ?? "";
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
                        'Location of scaffolding',
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
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.streetAddress,
                        decoration: const InputDecoration(
                            hintText: 'Enter the location of scaffolding'),
                        validator: (location) {
                          if (location!.isEmpty) {
                            return "Please enter a location";
                          }
                          return null;
                        },
                        onSaved: (location) {
                          _formData['location'] = location ?? "";
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
                        'Client name',
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
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                            hintText: 'Enter your client name'),
                        validator: (clientName) {
                          if (clientName!.isEmpty) {
                            return "Please enter client name";
                          }
                          return null;
                        },
                        onSaved: (clientName) {
                          _formData['clientName'] = clientName ?? "";
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
                        'Inspection date',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: blackColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              inspectionDate != null
                                  ? Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(inspectionDate!.toLocal()),
                                      style: TextStyle(
                                          fontSize: 16, color: blackColor),
                                    )
                                  : Text(
                                      'Select date of inspection',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                              Icon(Icons.calendar_month_outlined,
                                  color: Colors.grey.shade700),
                            ],
                          ),
                        ),
                      ),
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
                        'Duty of scaffold',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Select an item',
                          border: InputBorder.none,
                          suffixIcon: DropdownButtonFormField(
                            value: selectedDuty,
                            onChanged: (newValue) {
                              setState(() {
                                selectedDuty = newValue as String;
                              });
                              // print(selectedDuty);
                            },
                            items: duties
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
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
                        'Scaffold measurement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 16, color: blackColor),
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(hintText: 'Enter length'),
                        validator: (length) {
                          if (length!.isEmpty) {
                            return "Please enter length";
                          }
                          return null;
                        },
                        onSaved: (length) {
                          _formData['length'] = length ?? "";
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 16, color: blackColor),
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(hintText: 'Enter width'),
                        validator: (width) {
                          if (width!.isEmpty) {
                            return "Please enter width";
                          }
                          return null;
                        },
                        onSaved: (width) {
                          _formData['width'] = width ?? "";
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 16, color: blackColor),
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(hintText: 'Enter height'),
                        validator: (height) {
                          if (height!.isEmpty) {
                            return "Please enter height";
                          }
                          return null;
                        },
                        onSaved: (height) {
                          _formData['height'] = height ?? "";
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 16, color: blackColor),
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(hintText: 'Enter volume'),
                        validator: (volume) {
                          if (volume!.isEmpty) {
                            return "Please enter volume";
                          }
                          return null;
                        },
                        onSaved: (volume) {
                          _formData['volume'] = volume ?? "";
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type of scaffold',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Select a type',
                          border: InputBorder.none,
                          suffixIcon: DropdownButtonFormField(
                            value: selectedScaffold,
                            onChanged: (newValue) {
                              setState(() {
                                selectedScaffold = newValue as String;
                              });
                              // print(selectedDuty);
                            },
                            items: scaffold
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
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
                        'Tag re-inspection date',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: blackColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => _selectReInspectionDate(context),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              tagReInspectionDate != null
                                  ? Text(
                                      DateFormat('yyyy-MM-dd').format(
                                          tagReInspectionDate!.toLocal()),
                                      style: TextStyle(
                                          fontSize: 16, color: blackColor),
                                    )
                                  : Text(
                                      'Select date of re-inspection',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                              Icon(Icons.calendar_month_outlined,
                                  color: Colors.grey.shade700),
                            ],
                          ),
                        ),
                      ),
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
                        'Tag remove date',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: blackColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => _selectTagremoveDate(context),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              tagRemoveDate != null
                                  ? Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(tagRemoveDate!.toLocal()),
                                      style: TextStyle(
                                          fontSize: 16, color: blackColor),
                                    )
                                  : Text(
                                      'Select date of tag remove',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                              Icon(Icons.calendar_month_outlined,
                                  color: Colors.grey.shade700),
                            ],
                          ),
                        ),
                      ),
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
                        'Scaffolding hand safety checklist',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: blackColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          return CheckboxListTile(
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              data[i],
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            value: userChecked.contains(data[i]),
                            onChanged: (val) {
                              _onSelected(val!, data[i]);
                              // print(userChecked.toString());
                            },
                            //you can use checkboxlistTile too
                          );
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
                        'Inspected by',
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
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                            hintText: 'Enter inspector name'),
                        validator: (inspector) {
                          if (inspector!.isEmpty) {
                            return "Please enter inspector name";
                          }
                          return null;
                        },
                        onSaved: (inspector) {
                          _formData['inspector'] = inspector ?? "";
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
                        'Inspection Image',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: blackColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          await pickImage();
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: inspectionImage == null
                                ? Text(
                                    'Select image',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 16),
                                  )
                                : Container(
                                    width: 300,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          File(
                                            inspectionImage!.path ?? "",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: MaterialButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addData();
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
                              'Save',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
