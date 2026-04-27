import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/usecase/auth2/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  final _userRepo = UserRepository();

  User? _user = null;

  bool isLoading = false;

  User get user {
    if (_user == null) {
      _authService.getCurrentUser().then(
        (user) => {
          if (user != null) {_user = user},
        },
      );
    }

    return _user!;
  }


  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = user;

    setState(() {
      nameController.text = data.firstName ?? '';
      phoneController.text = data.phone ?? '';
    });
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    await _userRepo.update(user.uid, {
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
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
