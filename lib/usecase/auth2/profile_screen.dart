import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    final data = doc.data();

    setState(() {
      nameController.text = data?['name'] ?? '';
      phoneController.text = data?['phone'] ?? '';
    });
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .update({
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: isLoading ? null : updateProfile,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}