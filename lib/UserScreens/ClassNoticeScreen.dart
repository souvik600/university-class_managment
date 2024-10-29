import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../AppColors/AppColors.dart';
import '../Style/BackgroundStyle.dart';
import '../Style/CustomAppBar.dart';

class Notice {
  final String text;
  final String? imageUrl;
  final DateTime dateTime;

  Notice({
    required this.text,
    this.imageUrl,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrl': imageUrl,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Notice.fromMap(Map<String, dynamic> map) {
    return Notice(
      text: map['text'],
      imageUrl: map['imageUrl'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}

class ClassNoticeScreen extends StatefulWidget {
  @override
  _ClassNoticeScreenState createState() => _ClassNoticeScreenState();
}

class _ClassNoticeScreenState extends State<ClassNoticeScreen> {
  final List<Notice> _notices = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingNotices = true; // Loading state for notices

  @override
  void initState() {
    super.initState();
    _loadNoticesFromFirestore();
  }

  String formatDateWithDay(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference <= 7) {
      return DateFormat('HH:mm EEEE').format(dateTime);
    } else {
      return DateFormat('HH:mm dd-MM-yyyy').format(dateTime);
    }
  }

  Future<void> _loadNoticesFromFirestore() async {
    setState(() {
      _isLoadingNotices = true; // Start loading
    });

    final noticeSnapshot = await FirebaseFirestore.instance.collection('notice').get();
    setState(() {
      _notices.clear();
      _notices.addAll(noticeSnapshot.docs.map((doc) => Notice.fromMap(doc.data())).toList());
      _isLoadingNotices = false; // Stop loading
    });

    _scrollToTop();
  }

  Future<void> _addNoticeToFirestore(Notice notice) async {
    await FirebaseFirestore.instance.collection('notice').add(notice.toMap());
    _loadNoticesFromFirestore();
  }

  Future<void> _deleteNoticeFromFirestore(String docId) async {
    await FirebaseFirestore.instance.collection('notice').doc(docId).delete();
    _loadNoticesFromFirestore();
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child("images/$fileName");
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addNotice() async {
    final text = _textController.text;

    if (text.isNotEmpty || _selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _uploadImageToFirebase(_selectedImage!);
      }

      final notice = Notice(
        text: text,
        imageUrl: imageUrl,
        dateTime: DateTime.now(),
      );

      await _addNoticeToFirestore(notice);

      _textController.clear();
      setState(() {
        _selectedImage = null;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text or select an image')),
      );
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Class Notice'),
      body: Stack(
        children: [
          ScreenBackground(context),
          Column(
            children: [
              if (_isLoadingNotices) // Show the LinearProgressIndicator while loading
                LinearProgressIndicator(),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('notice').orderBy('dateTime', descending: true).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var notices = snapshot.data!.docs
                        .map((doc) => MapEntry(doc.id, Notice.fromMap(doc.data() as Map<String, dynamic>)))
                        .toList();

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: notices.length,
                      itemBuilder: (context, index) {
                        final noticeId = notices[index].key;
                        final notice = notices[index].value;

                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Notice'),
                                  content: const Text('Are you sure you want to delete this notice?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteNoticeFromFirestore(noticeId);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.pColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.pColor,
                                width: 2.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (notice.imageUrl != null)
                                  Image.network(notice.imageUrl!),
                                if (notice.text.isNotEmpty)
                                  SizedBox(height: 5,),
                                  Text(
                                    notice.text,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'kalpurush',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                const SizedBox(height: 5),
                                Text(
                                  formatDateWithDay(notice.dateTime),
                                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.pColor.withOpacity(0.2),
                  border: Border.all(
                    color: AppColors.pColor,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    if (_selectedImage == null) ...[
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.blue),
                        onPressed: _takePhoto,
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.green),
                        onPressed: _pickImageFromGallery,
                      ),
                    ],
                    if (_selectedImage != null)
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: FileImage(_selectedImage!),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Type your notice here...',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: _isLoading
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.send, color: Colors.purple, size: 35),
                      onPressed: _isLoading ? null : _addNotice,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
