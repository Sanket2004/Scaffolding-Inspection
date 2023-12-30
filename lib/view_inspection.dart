import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scaffolding/colors.dart';

class ViewInspectionPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const ViewInspectionPage({super.key, required this.data});

  @override
  State<ViewInspectionPage> createState() => _ViewInspectionPageState();
}

class _ViewInspectionPageState extends State<ViewInspectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          widget.data['title'],
          style: TextStyle(
              fontSize: 20, color: textColor, fontWeight: FontWeight.w400),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0))),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: null,
                        body: Stack(
                          children: [
                            Scaffold(
                              extendBodyBehindAppBar: true,
                              body: PhotoViewGallery.builder(
                                itemCount: 1,
                                builder: (context, index) {
                                  return PhotoViewGalleryPageOptions(
                                    imageProvider: NetworkImage(
                                        widget.data['inspectionImage']),
                                    minScale: PhotoViewComputedScale.contained,
                                    maxScale:
                                        PhotoViewComputedScale.covered * 2,
                                  );
                                },
                                scrollPhysics: const BouncingScrollPhysics(),
                                backgroundDecoration: const BoxDecoration(
                                  color: Colors
                                      .black, // Change this color to your desired background color
                                ),
                                pageController: PageController(),
                                onPageChanged: (index) {
                                  // Do something when the page changes
                                },
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 20.0,
                              left: 20.0,
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.data['title'],
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: textColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            widget.data['inspectedBy'],
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: textColor,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy').format(
                                                widget.data['inspectionDate']
                                                    .toDate()),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 10.0,
                              right: 10.0,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the photo_view screen
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: primaryColor.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.data['inspectionImage'] != null
                        ? Image.network(
                            widget.data['inspectionImage'],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // Image is fully loaded, display it.
                              } else {
                                return Center(
                                  child: Container(
                                    width: 80,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Loading'),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        LinearProgressIndicator(
                                          minHeight: 5,
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                        : const Text('Loading'),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Basic Details',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primaryColor.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '\u2022',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Location: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          widget.data['location'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '\u2022',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Client name: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          widget.data['clientName'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '\u2022',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Inspection date: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy')
                              .format(widget.data['inspectionDate'].toDate()),
                          style: TextStyle(
                            fontSize: 16,
                            color: blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Scaffold Details',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primaryColor.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '\u2022',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Duty of scaffold: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          widget.data['dutyOfScaffold'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '\u2022',
                              style:
                                  TextStyle(fontSize: 16, color: primaryColor),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Sacffold mesasurement: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Row(
                            children: [
                              Text(
                                '\u2022',
                                style: TextStyle(
                                    fontSize: 16, color: primaryColor),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                'Height: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                widget.data['scaffoldHeight'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Row(
                            children: [
                              Text(
                                '\u2022',
                                style: TextStyle(
                                    fontSize: 16, color: primaryColor),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                'Width: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                widget.data['scaffoldWidth'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Row(
                            children: [
                              Text(
                                '\u2022',
                                style: TextStyle(
                                    fontSize: 16, color: primaryColor),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                'Length: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                widget.data['scaffoldLength'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Row(
                            children: [
                              Text(
                                '\u2022',
                                style: TextStyle(
                                    fontSize: 16, color: primaryColor),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                'Volume: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                widget.data['scaffoldVolume'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '\u2022',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Type of scaffold: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          widget.data['scaffoldType'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '\u2022',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Tag re-inspection date: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy').format(
                              widget.data['tagReInspectionDate'].toDate()),
                          style: TextStyle(
                            fontSize: 16,
                            color: blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '\u2022',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Tag remove date: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy')
                              .format(widget.data['tagRemoveDate'].toDate()),
                          style: TextStyle(
                            fontSize: 16,
                            color: blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Scaffold Hand Safety Checklist',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primaryColor.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var item in widget.data['handSafetyChecklist'])
                      Row(
                        children: [
                          Text(
                            '\u2022',
                            style: TextStyle(fontSize: 16, color: primaryColor),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            item, // Adjust the separator as needed
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Inspected By',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primaryColor.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data['inspectedBy'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy')
                              .format(widget.data['inspectionDate'].toDate()),
                          style: TextStyle(
                            fontSize: 13,
                            color: blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class $ {}
