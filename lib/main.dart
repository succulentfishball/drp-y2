import 'package:flutter/material.dart';
import 'package:drp/timeline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DRP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker picker = ImagePicker();
  // todo need better user, time formats to align with database
  final List<PhotoWidget> photos = [
    PhotoWidget(
      imageUrl: 'https://picsum.photos/200',
      datetime: '2025-05-30 xx:xx',
      user: 'User1',
      caption: 'Hello\nWorld',
    ),
    PhotoWidget(
      imageUrl: 'https://picsum.photos/200',
      datetime: '2025-05-30 xx:xx',
      user: 'User2',
      caption: '',
    ),
    // add more sample photos here
  ];

  void uploadPhoto(String imagePath) {
    // todo need to upload to database
    String imageUrl = 'https://picsum.photos/200';

    // todo need error handlers if not updated to database, then dont update local timeline

    // add to timeline
    setState(() {
      photos.add(
        PhotoWidget(
          imageUrl: imageUrl,
          datetime: DateTime.now().toIso8601String(),
          user: 'user1',
          caption: 'A beautiful day',
        )
      );
    });
  }

  Future<void> takePhoto() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      uploadPhoto(photo.path);
    }
  }

  void openCalendar() {
    // todo open calendar functionality
  }

  Future<void> pickPhoto() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      uploadPhoto(photo.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text('30 May 2025'),
      ),
      body: Center(
        child: TimelineWidget(photos: photos),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {takePhoto();},
        tooltip: 'Take a picture',
        shape: CircleBorder(),
        child: const Icon(Icons.camera_alt),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.primary,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Spacer(),
            IconButton(
              onPressed: () {openCalendar();},
              tooltip: 'Open calendar',
              icon: Icon(Icons.calendar_month_outlined, color: Theme.of(context).colorScheme.onPrimary, size: 30.0)
            ),
            Spacer(), Spacer(), Spacer(), Spacer(),
            IconButton(
              onPressed: () {pickPhoto();},
              tooltip: 'Pick Photo',
              icon: Icon(Icons.photo_album_outlined, color: Theme.of(context).colorScheme.onPrimary, size: 30.0)
            ),
            Spacer(),
          ],
        )
      ),
    );
  }
}
