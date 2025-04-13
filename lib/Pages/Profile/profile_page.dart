import 'package:app/Pages/Profile/profile_model.dart/profile_background.dart';
import 'package:app/Pages/Profile/profile_model.dart/profile_form.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: const [
          ProfileBackgroundDecoration(),
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: ProfileForm(),
          ),
        ],
      ),
    );
  }
}
