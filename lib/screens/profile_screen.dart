import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../core/providers/auth_provider.dart';
import '../core/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showEditProfileDialog(BuildContext context, CholoUser user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final ageCtrl = TextEditingController(text: user.age?.toString() ?? '');
    final universityNameCtrl = TextEditingController(text: user.universityName);
    String selectedGender = user.gender.isNotEmpty ? user.gender : 'Male';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedGender = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: universityNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'University Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final updates = <String, dynamic>{
          'name': nameCtrl.text.trim(),
          'gender': selectedGender,
          'universityName': universityNameCtrl.text.trim(),
        };
        
        final ageText = ageCtrl.text.trim();
        if (ageText.isNotEmpty) {
          updates['age'] = int.tryParse(ageText);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update(updates);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _uploadProfilePicture(BuildContext context, String userId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      if (!context.mounted) return;
      
      // Show loading
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Uploading...'),
            ],
          ),
        ),
      );

      try {
        // Upload to Firebase Storage (cross-platform)
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');
        
        // Read image bytes (works on all platforms)
        final bytes = await image.readAsBytes();
        
        // Upload with timeout
        final uploadTask = await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Upload timeout - please check your internet connection');
          },
        );
        
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'profilePictureUrl': downloadUrl,
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Firestore update timeout');
          },
        );
        
        // Close loading dialog
        navigator.pop();
        
        // Show success message
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        // Close loading dialog
        navigator.pop();
        
        // Show error message
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture with Upload Button
                  Center(
                    child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white24,
                        backgroundImage: user.profilePictureUrl.isNotEmpty
                            ? NetworkImage(user.profilePictureUrl)
                            : null,
                        child: user.profilePictureUrl.isEmpty
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                            padding: EdgeInsets.zero,
                            onPressed: () => _uploadProfilePicture(context, user.id),
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.universityEmail,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  if (user.age != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.cake, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Age: ${user.age}'),
                      ],
                    ),
                  ],
                  if (user.gender.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Gender: ${user.gender}'),
                      ],
                    ),
                  ],
                  if (user.universityName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.school, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('University: ${user.universityName}'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showEditProfileDialog(context, user),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                user.averageRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(' (${user.ratingCount} reviews)', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/view_ratings', arguments: user.id),
                              child: const Text('View All Ratings'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
