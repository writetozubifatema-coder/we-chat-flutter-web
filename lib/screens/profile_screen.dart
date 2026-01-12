// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/auth/login_screen.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final Chatuser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _image;

  final TextEditingController _nameController = TextEditingController();
final TextEditingController _aboutController = TextEditingController();


@override
void initState() {
  super.initState();
  _nameController.text = widget.user.displayName;
  _aboutController.text = widget.user.about;
}


@override
void dispose() {
  _nameController.dispose();
  _aboutController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),

        // 🔴 LOGOUT BUTTON
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showprogressbar(context);

              await Api.updateActiveStatus(false);
              await Api.auth.signOut();
              await GoogleSignIn().signOut();
              await Api.saveUserToFirestore();
              


              if (!mounted) return;

              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: mq.height * .03),

                // 🔹 PROFILE IMAGE
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: _image != null
                          ? Image.file(
                              File(_image!),
                              width: mq.height * 0.2,
                              height: mq.height * 0.2,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.user.photoURL,
                              width: mq.height * 0.2,
                              height: mq.height * 0.2,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const CircleAvatar(
                                radius: 80,
                                child: Icon(Icons.person, size: 80),
                              ),
                            ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: showBottomSheet,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: mq.height * .03),

                // 🔹 EMAIL
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: mq.height * .04),

                // 🔹 NAME
                 TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: 'Name',
        ),
                 ),


                SizedBox(height: mq.height * .03),
                

                // 🔹 ABOUT
                TextFormField(
  controller: _aboutController,
  decoration: InputDecoration(
    prefixIcon: const Icon(Icons.info_outline, color: Colors.blue),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    labelText: 'About',
  ),
),



                SizedBox(height: mq.height * .05),

                // 🔹 UPDATE BUTTON
                ElevatedButton.icon(
                  onPressed: () async {
                    Dialogs.showprogressbar(context);

                    await Api.updateUserInfo(
                      name: _nameController.text.trim(),
                      about: _aboutController.text.trim(),
                    );

                    if (!mounted) return;
                    Navigator.pop(context);

                    Dialogs.showsnackbar(
                        context, 'Profile updated');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize:
                        Size(mq.width * 0.5, mq.height * 0.06),
                  ),
                  icon: const Icon(Icons.edit),
                  label:
                      const Text('UPDATE', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔽 IMAGE PICKER BOTTOM SHEET
  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * .03,
            bottom: mq.height * .05,
          ),
          children: [
            const Text(
              'Pick Profile picture',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: mq.height * .03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize:
                        Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(
                            source: ImageSource.gallery);
                    if (image == null) return;

                    setState(() => _image = image.path);
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/images/gallery.png',
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize:
                        Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? photo =
                        await picker.pickImage(
                            source: ImageSource.camera);
                    if (photo == null) return;

                    setState(() => _image = photo.path);
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/images/camera.jpg',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
