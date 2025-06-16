import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drp/data_types/comment.dart';
import 'package:drp/data_types/my_image.dart';
import 'package:drp/data_types/my_post_record.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:drp/utilities/global_vars.dart';
import 'package:drp/utilities/toaster.dart' show Toaster;
import 'package:drp/utilities/utils.dart';
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

  static Future<int> getNumberOfRepliesToPost(MyPost? post) async {
    if (post != null) {
      final chatMessages = await dbRef.collection("Group_Data").doc(groupID!).collection("Chat").doc(post.chatID!).collection("Messages").get();
      return chatMessages.docs.length - 1;
    } else {
      return 0;
    }
  }

  static Future<Uint8List?> fetchImageFromCloudByID(String imgID) async {
    final ref = storageRef.child("images/$groupID/$imgID.jpg");
    try {
      print("Trying to download $imgID from cloud...");
      const fileSizeCap = 10 * 1024 * 1024; // 10MB
      return await ref.getData(fileSizeCap);
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

  static Future<List<String>> getRecentTags() async {
    final userId = userID; // assume this is your static current‐user ID
    // 1) Fetch the latest 50 posts by timestamp only:
    final snapshot = await FirebaseFirestore.instance
        .collection('Group_Data')
        .doc(groupID)
        .collection("Posts")
        .orderBy('postTime', descending: true)  // single‐field index only
        .limit(50)
        .get();

    // 2) Walk through in order, picking out up to 2 distinct tags for this user
    final seen = <String>{};
    final recent = <String>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['authorID'] == userId) {
        final tag = (data['tag'] as String?)?.trim();
        if (tag != null && tag.isNotEmpty && seen.add(tag)) {
          recent.add(tag);
          if (recent.length == 2) break;
        }
      }
    }
    return recent;
  }

  // Quantitative analysis
  static Future<void> incrementTotalPosts() async { await incrementQuantitativeField("totalPosts"); }

  static Future<void> incrementTotalComments() async { await incrementQuantitativeField("totalComments"); }

  static Future<void> incrementPostsOpened() async { await incrementQuantitativeField("postsOpened"); }

  static Future<void> incrementTagsUsed() async { await incrementQuantitativeField("tagsUsed"); }

  static Future<void> incrementQuantitativeField(String field) async {
    if (testMode) { return; }

    final ref = dbRef.doc('Group_Data/$groupID/Quantitative_Data/${reverseDateFormat(DateTime.now())}');
    final snapshot = await ref.get();
    final value = snapshot.data()?[field];
    if (value != null) {
      ref.update({field: value + 1});
    } else {
      Map<String, dynamic> m = snapshot.data() ?? {};
      m.addEntries({field: 1}.entries);
      ref.set(m);
    }
  }

  static Future<void> addToPostsHistory(MyPostRecord record) async { await addRecordToHistory(record, "postHistory"); }

  static Future<void> addRecordToHistory(dynamic record, String field) async {
    if (testMode) { return; }

    final ref = dbRef.doc('Group_Data/$groupID/Quantitative_Data/${reverseDateFormat(DateTime.now())}');
    final snapshot = await ref.get();
    final List<dynamic>? value = snapshot.data()?[field];
    print(record.toString());
    if (value != null) {
      value.add(record.toFirestore());
      ref.update({field: value});
    } else {
      Map<String, dynamic> m = snapshot.data() ?? {};
      m[field] = [record.toFirestore()];
      ref.set(m);
    }
  } 
}