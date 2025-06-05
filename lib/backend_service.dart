import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drp/image.dart';
import 'package:drp/main.dart';
import 'package:drp/post.dart';
import 'package:drp/toaster.dart' show Toaster;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

const maxUsernameLength = 5;

class BackEndService {
  static String? userID;
  static String? groupID;

  static final dbRef = FirebaseFirestore.instance;
  static final storageRef = FirebaseStorage.instance.ref();


  // Static factory
  Future<void> initialise() async {
    // Do initialization that requires async
    if (groupID == null || userID == null) { await _asyncInit(); }

    // Check if user needs a username / groupID
    try {
      final res = await dbRef.collection("Users").doc(userID).get();
      res["groupID"]; res["name"];
    } catch(e) {
      BackEndService.setUserData(FirebaseAuth.instance.currentUser!.uid);
    }

    // Return the fully initialized object
    print("Returning backend service");
  }

  Future<void> _asyncInit() async {
    userID = FirebaseAuth.instance.currentUser!.uid;
    try {
      final snapshot = await dbRef.collection("Users").doc(userID).get();
      groupID = snapshot["groupID"];
    } catch (e) {
      print(e);
    }
  }

  static Future<String?> fetchNameFromUUID(String uid) async {
    final snapshot = await dbRef.collection("Users").doc(uid).get();
    return snapshot["name"];
  } 

  static Future<List<Post>> fetchAllPostsFromGroup() async {
    final res = await dbRef.collection("Group_Data").doc(groupID).collection("Posts").get();
    List<Post> posts = List.empty(growable: true);
    for (final doc in res.docs) {
      posts.add(Post.fromFirestore(doc, null));
    }
    return posts;
  } 

  static Future<Uint8List?> fetchImageFromCloudByID(String imgID) async {
    final islandRef = storageRef.child("images/$groupID/$imgID.jpg");
    try {
      const oneMegabyte = 1024 * 1024;
      return await islandRef.getData(oneMegabyte);
    } on FirebaseException catch (e) {
      Toaster().displayAuthToast("Failed to retrieve image from cloud... Error: $e");
      return null;
    }
  }

  static Future<MyImage?> fetchImageDataFromDB(String imgID) async {
    final snapshot = await dbRef.collection("Group_Data").doc(groupID).collection("Images").doc(imgID).get();
    return MyImage.fromFirestore(snapshot, null);
  } 

  static String? getGroupID() { return groupID; }

  static Future<void> setUserData(String uid) async {
    await dbRef.collection("Users").doc(uid).set({
      "groupID": dummyGroupID,
      "name": FirebaseAuth.instance.currentUser!.email!.substring(0,maxUsernameLength)
    });
  }

  static clearUserData() {
    userID = null; groupID = null;
  }
}