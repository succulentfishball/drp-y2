import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class FamilyMembersPage extends StatelessWidget {
  final List<String> familyMembers = ["You", "Husband", "Son", "Daughter"];

  void sendPoke(BuildContext context, String toUser) async {

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to poke.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('pokes').add({
        'fromUser': currentUser.displayName ?? currentUser.email ?? 'Unknown', // Replace with current logged-in user if needed
        'toUser': toUser,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Poked $toUser!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to poke $toUser.")),
      );
      print("Error sending poke: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("4 June 2025"),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.people),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Family Members",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: familyMembers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final name = familyMembers[index];
                final isYou = name == "You";
                return ListTile(
                  title: Text(name),
                  trailing: isYou
                      ? null
                      : ElevatedButton.icon(
                          onPressed: () => sendPoke(context, name),
                          icon: const Icon(Icons.back_hand, color: Colors.orange),
                          label: const Text("Poke"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black,
                          ),
                        ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
