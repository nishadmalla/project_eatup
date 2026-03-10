import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 
import 'package:project_eatup/core/api/api_config.dart'; // ✅ Imported Config
import 'package:project_eatup/core/services/storage/token_service.dart';
import 'package:project_eatup/features/auth/presentation/pages/signin_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  String _userName = "Loading...";
  String _userEmail = "Loading...";
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); 
  }

  Future<void> _fetchUserData() async {
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();

    if (token == null || token.isEmpty) return;

    try {
      // ✅ Now uses ApiConfig instead of 10.0.2.2
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/me'); 
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data'] ?? data['user'] ?? data;

        if (mounted) {
          setState(() {
            _userName = userData['fullName'] ?? userData['username'] ?? "Foodie";
            _userEmail = userData['email'] ?? "No email available";
            _profileImageUrl = userData['profileImage'];
          });
        }
      } else if (response.statusCode == 401) {
        _handleSessionExpired();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = "Error loading name";
          _userEmail = "Error loading email";
        });
      }
    }
  }

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

  Future<void> _uploadProfileImage(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      final tokenService = ref.read(tokenServiceProvider);
      final token = tokenService.getToken();

      if (token == null || token.isEmpty) {
        _showSnack('Session expired. Please log in again.', Colors.red);
        _handleSessionExpired();
        return;
      }

      // ✅ Now uses ApiConfig instead of 10.0.2.2
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/update-profile');
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage', 
          imageFile.path,
          contentType: MediaType('image', 'jpeg'), 
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(body);
        _showSnack(data['message'] ?? 'Profile image updated!', Colors.green);
        _fetchUserData(); 

      } else if (response.statusCode == 401) {
        _showSnack('Session expired. Please log in again.', Colors.red);
        _handleSessionExpired();
      } else {
        final data = json.decode(body);
        _showSnack(data['message'] ?? 'Upload failed', Colors.red);
      }
    } catch (e) {
      _showSnack('Upload error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _handleSessionExpired() async {
    final tokenService = ref.read(tokenServiceProvider);
    await tokenService.removeToken();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  void _logout() async {
    final tokenService = ref.read(tokenServiceProvider);
    await tokenService.removeToken();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false, 
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final granted = await _requestPermission(source);
    if (!granted) {
      _showSnack('Permission denied', Colors.orange);
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _profileImage = file);
      await _uploadProfileImage(file);
    }
  }

  void _showImageSourceSheet() {
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
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.green),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImage != null 
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null
                                // ✅ Now uses ApiConfig instead of 10.0.2.2
                                ? NetworkImage('${ApiConfig.baseUrl}$_profileImageUrl')
                                : null) as ImageProvider?,
                        child: _profileImage == null && _profileImageUrl == null
                            ? const Icon(Icons.person, size: 65, color: Colors.grey)
                            : null,
                      ),
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
                        onTap: _isUploading ? null : _showImageSourceSheet,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _userName, 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                _userEmail, 
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person_outline, color: Colors.orange),
                        ),
                        title: const Text("Edit Profile"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                           _showSnack('Edit profile coming soon!', Colors.orange);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red.shade400),
                        const SizedBox(width: 8),
                        Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}