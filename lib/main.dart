import 'dart:io';
import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/comment.dart';
import 'package:drp/data_types/enums.dart';
import 'package:drp/data_types/my_post_record.dart';
import 'package:drp/utilities/global_vars.dart' as global_vars;
import 'package:drp/utilities/toaster.dart';
import 'package:drp/utilities/utils.dart' as utils;
import 'package:firebase_auth/firebase_auth.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:drp/widgets/timeline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drp/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:native_exif/native_exif.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:drp/data_types/my_user.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:drp/data_types/my_image.dart';
import 'package:drp/pages/pre_post.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  final List<TimelineNodeWidget> photos = List.empty(growable: true);
  final List<GlobalKey<TimelineNodeWidgetState>> photoKeys = List.empty(growable: true);
  final DateTime currentPhotoDataTime = DateTime.now();

  // File data variables
  Exif? exif;

  // Firebase shenanigans
  final storageRef = FirebaseStorage.instance.ref(); 
  final dbRef = FirebaseFirestore.instance;

  // May break if exif can't read "creationTime" from file
  void uploadPhoto(XFile file, String caption, String? tag) async {
    BackEndService.incrementTotalPosts();
    if (tag != null) { 
      BackEndService.incrementTagsUsed();
    }

    // Get meta data and file data
    final exif = await Exif.fromPath(file.path);
    final bytes = await File(file.path).readAsBytes();
    String imgID = Uuid().v1().toString();
    
    try {
      final fileRef = storageRef.child("images/${userData!.groupID!}/$imgID.jpg");

      // Upload image to Firebase Storage
      try {
        await fileRef.putData(bytes);

        // Reject image if meta data can't be read
        final originalDate = await exif.getOriginalDate();
        if (originalDate == null) {
          throw Exception("Can not read meta data in image, only images taken from phone camera may be uploaded.");
        }

        // Upload image data
        MyImage newImg = MyImage(ownerID: BackEndService.userID, creationTime: originalDate);
        await dbRef.collection("Group_Data").doc(userData!.groupID!).collection("Images").doc(imgID).set(
          newImg.toFirestore()
        );

        // Upload post and correlating chat data
        final postID = Uuid().v1();
        final chatID = Uuid().v1();
        MyPost newPost = MyPost(
          authorID: BackEndService.userID, 
          imageIDs: [imgID], 
          chatID: chatID,
          caption: caption, 
          tag: tag,
          postTime: DateTime.now(),
          timeFirstImageTaken: originalDate
        );
        Comment initialComment = Comment(
          authorID: BackEndService.userID,
          postTime: DateTime.now(),
          message: caption
        );
        await dbRef.collection("Group_Data").doc(userData!.groupID!).collection("Posts").doc(postID).set(
          newPost.toFirestore()
        );
        await dbRef.collection("Group_Data").doc(userData!.groupID).collection("Chat").doc(chatID).collection("Messages").doc().set(
          initialComment.toFirestore()
        );

        setState(() {
          BackEndService.addToPostsHistory(MyPostRecord(
            authorID: BackEndService.userID,
            method: global_vars.currentPostingMethod,
            uploadTime: DateTime.now(),
            postWritingDuration: DateTime.now().difference(global_vars.startingPostTime!),
            tag: tag
          ));
          global_vars.startingPostTime = null;
          global_vars.currentPostingMethod = null;
        });

      } on firebase_core.FirebaseException catch (e) {
        print(e);
        Toaster().displayAuthToast("Failed to upload image");
      }
    } catch (e) {
      print(e);
      Toaster().displayAuthToast("Error: ${e.toString()}");
    }
  }

  Future<void> takePhoto() async {
    global_vars.startingPostTime = DateTime.now();
    global_vars.currentPostingMethod = Method.camera;

    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrePostPage(
            imageFile: photo,
            onPost: ({required String caption, String? tag, required XFile image}) {
              // Replace this with your actual upload logic
              uploadPhoto(image, caption, tag);
              print("Caption: $caption");
              print("Tag: $tag");
            },
          ),
        ),
      );
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
    global_vars.startingPostTime = DateTime.now();
    global_vars.currentPostingMethod = Method.gallery;

    final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 5);
    if (photo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrePostPage(
            imageFile: photo,
            onPost: ({required String caption, String? tag, required XFile image}) {
              // Replace this with your actual upload logic
              uploadPhoto(image, caption, tag);
              print("Caption: $caption");
              print("Tag: $tag");
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building home page.");
    // Check if important data needs to be initialised/fetched before proceeding to generate UI via getMainInterface()
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
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
        title: Text(utils.date(DateTime.now())),
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter Settings',
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
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
        stream: BackEndService.getAllPostSnapshotsFromGroup(), 
        builder: (context, snapshot) {
          print("At stream builder");
          if (snapshot.hasData) {
            photos.clear();
            for (final doc in snapshot.data!.docs) {              
              GlobalKey<TimelineNodeWidgetState> key = GlobalKey<TimelineNodeWidgetState>();
              photos.add(TimelineNodeWidget(key: key, post: MyPost.fromFirestore(doc, null)));
              photoKeys.add(key);
            }

            photos.sort((a, b) => (a.post.timeFirstImageTaken!.compareTo(b.post.timeFirstImageTaken!)));

            return Expanded(child: TimelineWidget(photos: photos, photoKeys: photoKeys));
          } else {
            return Text("No data for home page");
          }
        }
      ),
      floatingActionButton: SpeedDial(
        marginEnd: 32 + 8,
        marginBottom: 8,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        icon: Icons.add,
        activeIcon: Icons.remove,
        overlayOpacity: 0.0,
        children: [
          SpeedDialChild(
            child: Icon(Icons.photo_library_outlined),
            label: "Choose Photo",
            onTap: () {
              pickPhoto();
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
            label: "Take Photo",
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
