import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drp/data_types/comment.dart';
import 'package:drp/data_types/my_image.dart';
import 'package:drp/main.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:drp/utilities/toaster.dart' show Toaster;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

const maxUsernameLength = 5;

class BackEndService {
  static String? userID;
  static String? groupID;

  static final dbRef = FirebaseFirestore.instance;
  static final storageRef = FirebaseStorage.instance.ref();


  // Static factory
  Future<void> initialise() async {
    // Do initialization that requires async
    if (groupID == null || userID == null) { 
      await _asyncInit(); 
      if (groupID == null) { await setUserData(userID!); }
    }

    // Return the fully initialized object
    print("Returning backend service");
  }

  Future<void> _asyncInit() async {
    try {
      userID = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await dbRef.collection("Users").doc(userID).get();
      groupID = snapshot["groupID"];
    } catch (e) {
      print("caught $e");
    }
  }

  static Future<String?> fetchNameFromUUID(String uid) async {
    final snapshot = await dbRef.collection("Users").doc(uid).get();
    return snapshot["name"];
  } 

  static Future<List<MyPost>> fetchAllPostsFromGroup() async {
    final res = await dbRef.collection("Group_Data").doc(groupID).collection("Posts").get();
    List<MyPost> posts = List.empty(growable: true);
    for (final doc in res.docs) {
      posts.add(MyPost.fromFirestore(doc, null));
    }
    return posts;
  } 

  // Care should be taken with snapshots to avoid StreamBuilders from breaking
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllPostSnapshotsFromGroup() {
    return dbRef.collection("Group_Data").doc(groupID!).collection("Posts").snapshots();
  } 

  static Future<Uint8List?> fetchImageFromCloudByID(String imgID) async {
    final ref = storageRef.child("images/$groupID/$imgID.jpg");
    try {
      print("Trying to download $imgID from cloud...");
      const fileSizeCap = 10 * 1024 * 1024; // 10MB
      return await islandRef.getData(fileSizeCap);
    } on FirebaseException catch (e) {
      print("Error encountered when downloading image from cloud");
      Toaster().displayAuthToast("Failed to retrieve image from cloud... Error: $e");
      return null;
    }
  }

  static Future<MyImage?> fetchImageDataFromDB(String imgID) async {
    final snapshot = await dbRef.collection("Group_Data").doc(groupID).collection("Images").doc(imgID).get();
    return MyImage.fromFirestore(snapshot, null);
  } 

  // Care should be taken with snapshots to avoid StreamBuilders from breaking
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCommentSnapshotsFromChat(chatID) {
    print("Getting comments");
    return dbRef.collection("Group_Data").doc(groupID!).collection("Chat").doc(chatID).collection("Messages").snapshots();
  } 

  static String? getGroupID() { return groupID; }

  static Future<void> addCommentToChatID(Comment comment, String chatID) async {
    await dbRef.collection("Group_Data").doc(groupID!)
               .collection("Chat").doc(chatID)
               .collection("Messages").doc(Uuid().v1()).set(
                comment.toFirestore()
               );
  } 

  static Future<void> setUserData(String uid) async {
    final randomGroupID = Uuid().v1();
    await dbRef.collection("Users").doc(uid).set({
      "groupID": testMode ? dummyGroupID : randomGroupID,
      "name": FirebaseAuth.instance.currentUser!.email!.substring(0,maxUsernameLength)
    });
    groupID = randomGroupID;
    print("groupID set to $randomGroupID");
  }

  static clearUserData() {
    userID = null; groupID = null;
  }
}