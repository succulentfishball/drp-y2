import 'package:flutter/material.dart';
import 'package:drp/timeline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:drp/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DRP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => (FirebaseAuth.instance.currentUser == null) ? const LoginModal() : const MyHomePage(),
        '/home': (context) => const MyHomePage(),
      },
      // home: const MyHomePage(),
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
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      user: 'User0',
      caption: '',
    ),
    PhotoWidget(
      imageUrl: 'https://picsum.photos/200',
      dateTime: DateTime.now(),
      user: 'User1',
      caption: 'Hello\nWorld',
    ),
    PhotoWidget(
      imageUrl: 'https://picsum.photos/200',
      dateTime: DateTime.now(),
      user: 'User1',
      caption: 'Hello\nWorld again',
    ),
    PhotoWidget(
      imageUrl: 'https://picsum.photos/200',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      user: 'User2',
      caption: '',
    ),
    // add more sample photos here
  ];
  List<GlobalKey<PhotoWidgetState>> photoKeys = [GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey()];
  final DateTime currentPhotoDataTime = DateTime.now();

  void uploadPhoto(String imagePath) {
    // todo need to upload to database
    // String imageUrl = 'https://picsum.photos/250';

    // todo need error handlers if not updated to database, then dont update local timeline

    // add to timeline
    setState(() {
      GlobalKey<PhotoWidgetState> key = GlobalKey();
      photos.add(
        PhotoWidget(
          key: key,
          imageUrl: imagePath,
          dateTime: DateTime.now(),
          user: 'user1',
          caption: 'A beautiful day',
        )
      );
      photoKeys.add(key);
    });
  }

  Future<void> takePhoto() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      uploadPhoto(photo.path);
    }
  }

  Future<void> openCalendar() async {
    // todo open calendar functionality
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picked ${DateFormat.yMMMMd().format(picked)}')),
      );
    }
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
        title: Text(DateFormat.yMMMMd().format(DateTime.now())),
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter Settings',
          onPressed: () {},
        ), 
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Account Settings',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => LoginModal(),
              );
            },
          ), 
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("helloWorld").snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return const Text("Loading...");
          final documents = snapshot.data!.docs;
          // String serializedDocuments = documents.map((doc) {
          //   return doc.data().toString(); // Convert each document to a string
          // }).join('\n');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: TimelineWidget(photos: photos, photoKeys: photoKeys)),
              // debug
              // Text(serializedDocuments),
            ]
          );
          return TimelineWidget(photos: photos, photoKeys: photoKeys);
        }
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
