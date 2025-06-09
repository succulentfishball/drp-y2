import 'dart:io';
import 'package:drp/backend_service.dart';
import 'package:drp/toaster.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:drp/timeline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drp/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:native_exif/native_exif.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:drp/user.dart';
import 'package:drp/post.dart';
import 'package:drp/image.dart';
import 'package:drp/family_members.dart';
import 'package:badges/badges.dart' as badges;
import 'package:drp/utils.dart' as utils;



const bool testMode = false;
const String dummyGroupID = "9366e9b0-415b-11f0-bf9f-b5479dd77560";
BackEndService? backendService;
MyUser? userData;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DRP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => (FirebaseAuth.instance.currentUser == null) ? const LoginModal() : const MyHomePage(),
        '/home': (context) => const MyHomePage(),
        '/members': (context) => FamilyMembersPage(),
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
  final List<TimelineNodeWidget> photos = List.empty(growable: true);
  final List<GlobalKey<TimelineNodeWidgetState>> photoKeys = List.empty(growable: true);
  final DateTime currentPhotoDataTime = DateTime.now();

  // File data variables
  Exif? exif;

  // Firebase shenanigans
  final storageRef = FirebaseStorage.instance.ref(); 
  final dbRef = FirebaseFirestore.instance;

  void uploadPhoto(XFile file) async {
    // String imageUrl = 'https://picsum.photos/250';
    // Get meta data and file data
    final exif = await Exif.fromPath(file.path);
    final bytes = await File(file.path).readAsBytes();
    String imgID = Uuid().v1().toString();
    
    try {
      final fileRef = storageRef.child("images/${userData!.groupID!}/$imgID.jpg");

      // Upload image to Firebase Storage
      try {
        await fileRef.putData(bytes);

        // Upload image data
        MyImage newImg = MyImage(ownerID: BackEndService.userID, creationTime: await exif.getOriginalDate());
        await dbRef.collection("Group_Data").doc(userData!.groupID!).collection("Images").doc(imgID).set(
          newImg.toFirestore()
        );

        // Upload post data
        final postID = Uuid().v1();
        Post newPost = Post(authorID: BackEndService.userID, imageIDs: [imgID], caption: "captions to be implemented", postTime: DateTime.now());
        await dbRef.collection("Group_Data").doc(userData!.groupID!).collection("Posts").doc(postID).set(
          newPost.toFirestore()
        );

        setState(() {});

      } on firebase_core.FirebaseException catch (e) {
        print(e);
        Toaster().displayAuthToast("Failed to upload image");
      }
    } catch (e) {
      print(e);
      Toaster().displayAuthToast("Error uploading post, please try again later.");
    }
  }

  Future<void> takePhoto() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      uploadPhoto(photo);
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
        SnackBar(content: Text('Picked ${utils.date(picked)}')),
      );
    }
  }

  Future<void> pickPhoto() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 5);
    if (photo != null) {
      uploadPhoto(photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null || BackEndService.groupID == null || BackEndService.userID == null) {
      print("initialisation build");
      return FutureBuilder(
        future: initialiseGlobalVars(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return Text('loading... please wait...');
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!) {
              return getMainInterface();
            } else if (snapshot.hasData && snapshot.data! == false) {
              return Text("Failed to intialise global variables...");
            } else {
              return Text("Unexpected event when initialising global variables.");
            }
          }
        }
      );
    } else {
      print("normal build");
      return getMainInterface();
    }
  }

  Future<bool> initialiseGlobalVars() async {
    print("initialise global vars");
    await BackEndService().initialise(); 
    final fetchedData = await dbRef.collection("Users").doc(BackEndService.userID).withConverter(
      fromFirestore: MyUser.fromFirestore,
      toFirestore: (MyUser user, _) => user.toFirestore(),
    ).get();
    userData = fetchedData.data();
    print("groupID: ${BackEndService.groupID}, userID: ${BackEndService.userID}, userData: $userData");
    return Future.value(userData != null && BackEndService.groupID != null && BackEndService.userID != null);
  }

  Widget getMainInterface() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(utils.date(DateTime.now())),
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter Settings',
          onPressed: () {},
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pokes')
                .where('toUser', isEqualTo: FirebaseAuth.instance.currentUser?.displayName ?? FirebaseAuth.instance.currentUser?.email)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              final hasNewPokes = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return IconButton(
                icon: badges.Badge(
                  showBadge: hasNewPokes,
                  badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                  position: badges.BadgePosition.topEnd(top: -2, end: -2),
                  child: const Icon(Icons.notifications),
                ),
                tooltip: 'Notifications',
                onPressed: () {
                  // TODO: Replace with actual poke inbox page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tapped notifications")),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Family Members',
            onPressed: () {
              Navigator.pushNamed(context, '/members');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: BackEndService.fetchAllPostsFromGroup(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return const Text("Loading...");
          // Clear and load in all posts
          photos.clear();
          for (final loadedPost in snapshot.data!) {
            GlobalKey<TimelineNodeWidgetState> key = GlobalKey<TimelineNodeWidgetState>();
            photos.add(TimelineNodeWidget(key: key, post: loadedPost));
            photoKeys.add(key);
            print("photo added"); 
          }
          photos.sort((a, b) => (a.post.postTime!.compareTo(b.post.postTime!)));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: TimelineWidget(photos: photos, photoKeys: photoKeys)),
            ]
          );
        }
      ),
      floatingActionButton: SpeedDial(
        marginEnd: MediaQuery.sizeOf(context).width - 32 - 4,
        marginBottom: 8,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: Icons.add,
        activeIcon: Icons.remove,
        overlayOpacity: 0.0,
        children: [
          SpeedDialChild(
            child: Icon(Icons.photo_library_outlined),
            onTap: () {
              pickPhoto();
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
            onTap: () {
              takePhoto();
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat
    );
  }
}
