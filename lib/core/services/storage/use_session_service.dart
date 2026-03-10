import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // 🔐 Request permission
  Future<bool> _requestPermission(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  // ☁️ Upload image
  Future<void> _uploadProfileImage(File imageFile, String token) async {
    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse('http://10.0.2.2:5050/api/auth/update-profile');

      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath('profileImage', imageFile.path),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _showSnack('Profile image updated!', Colors.green);
      } else {
        final data = json.decode(body);
        _showSnack(data['message'] ?? 'Upload failed', Colors.red);
      }
    } catch (e) {
      _showSnack('Upload error: $e', Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 📷 Pick image
  Future<void> _pickImage(ImageSource source, String token) async {
    final granted = await _requestPermission(source);
    if (!granted) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _profileImage = file);
      await _uploadProfileImage(file, token);
    }
  }

  // ⬆️ Bottom sheet
  void _showImageSourceSheet(String token) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Choose Image Source',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera, token);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.green),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, token);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 Replace with actual token from your backend
    const String token = 'YOUR_TOKEN_HERE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 80, color: Colors.grey)
                      : null,
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploading ? null : () => _showImageSourceSheet(token),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap camera icon to update profile picture',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
