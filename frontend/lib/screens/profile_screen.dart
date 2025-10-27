import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../providers/user_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController bioController;
  bool isEditing = false;
  bool loading = false;
  String? selectedGender;
  DateTime? selectedBirthday;

  // Use AppTheme colors
  static Color get primaryGold => AppTheme.primaryGold;
  static Color get darkGray => AppTheme.darkGray;
  static Color get backgroundColor => AppTheme.backgroundColor;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
    selectedGender = user?.gender;
    selectedBirthday = user?.birthday;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        // Reset to original values if canceling
        final user = context.read<UserProvider>().user;
        nameController.text = user?.name ?? '';
        emailController.text = user?.email ?? '';
        bioController.text = user?.bio ?? '';
        selectedGender = user?.gender;
        selectedBirthday = user?.birthday;
      }
    });
  }

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final token = userProvider.token;

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _authService.updateProfile(
        token: token,
        name: nameController.text,
        email: emailController.text,
        bio: bioController.text.isEmpty ? null : bioController.text,
        gender: selectedGender,
        birthday: selectedBirthday,
      );

      if (response.statusCode == 200) {
        // Update user in provider with the new data
        final userData = response.data['user'];
        final updatedUser = User.fromJson(userData);
        userProvider.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          setState(() {
            loading = false;
            isEditing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
        setState(() => loading = false);
      }
    }
  }

  Future<void> uploadProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() => loading = true);

      // Read image as bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // Check file size (limit to ~1MB before base64 encoding)
      if (imageBytes.length > 1000000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image is too large. Please choose a smaller image.',
              ),
            ),
          );
          setState(() => loading = false);
        }
        return;
      }

      // Convert to base64
      final String base64Image = base64Encode(imageBytes);
      final String imageData = 'data:image/jpeg;base64,$base64Image';

      final userProvider = context.read<UserProvider>();
      final token = userProvider.token;

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _authService.uploadProfilePicture(
        token: token,
        imageData: imageData,
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final updatedUser = User.fromJson(userData);
        userProvider.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
          setState(() => loading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
        );
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: darkGray.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Please log in to view your profile',
                style: TextStyle(fontSize: 18, color: darkGray),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Go to Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: EdgeInsets.all(isSmallScreen ? 20 : 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Management',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: darkGray,
                      ),
                    ),
                    if (!isEditing)
                      IconButton(
                        onPressed: toggleEdit,
                        icon: const Icon(Icons.edit),
                        color: primaryGold,
                        iconSize: 28,
                        tooltip: 'Edit Profile',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your personal information',
                  style: TextStyle(
                    fontSize: 16,
                    color: darkGray.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),

                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: primaryGold.withOpacity(0.2),
                        backgroundImage:
                            user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null || user.photoUrl!.isEmpty
                            ? Icon(Icons.person, size: 60, color: primaryGold)
                            : null,
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryGold,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: loading ? null : uploadProfilePicture,
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Profile Form
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          enabled: isEditing,
                          decoration: InputDecoration(
                            labelText: 'Your name',
                            labelStyle: TextStyle(color: darkGray),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryGold),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryGold,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          enabled: isEditing,
                          decoration: InputDecoration(
                            labelText: 'Your email',
                            labelStyle: TextStyle(color: darkGray),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryGold),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryGold,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Gender Field
                        Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isEditing
                                  ? primaryGold
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: isEditing
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Male'),
                                        value: 'Male',
                                        groupValue: selectedGender,
                                        activeColor: primaryGold,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Female'),
                                        value: 'Female',
                                        groupValue: selectedGender,
                                        activeColor: primaryGold,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Other'),
                                        value: 'Other',
                                        groupValue: selectedGender,
                                        activeColor: primaryGold,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    selectedGender ?? 'Not specified',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: darkGray,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Birthday Field
                        Text(
                          'Birthday',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: isEditing
                              ? () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedBirthday ??
                                        DateTime(2000, 1, 1),
                                    firstDate: DateTime(1940),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: primaryGold,
                                            onPrimary: Colors.white,
                                            onSurface: darkGray,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      selectedBirthday = picked;
                                    });
                                  }
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isEditing
                                    ? primaryGold
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedBirthday == null
                                      ? 'Select Birthday'
                                      : '${selectedBirthday!.day}/${selectedBirthday!.month}/${selectedBirthday!.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: selectedBirthday == null
                                        ? darkGray.withOpacity(0.6)
                                        : darkGray,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: isEditing
                                      ? primaryGold
                                      : Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bio Field
                        Text(
                          'Bio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: bioController,
                          enabled: isEditing,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Tell us about yourself',
                            labelStyle: TextStyle(color: darkGray),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryGold),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryGold,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Buttons
                        if (isEditing)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: loading ? null : toggleEdit,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: BorderSide(color: primaryGold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: primaryGold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: loading ? null : saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGold,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Save Changes',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Account Settings Section
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.lock, color: primaryGold),
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to change password screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Change password coming soon!'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.notifications, color: primaryGold),
                        title: const Text('Notification Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to notification settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notification settings coming soon!',
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.privacy_tip, color: primaryGold),
                        title: const Text('Privacy Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to privacy settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Privacy settings coming soon!'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Account'),
                              content: const Text(
                                'Are you sure you want to delete your account? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // TODO: Implement account deletion
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Account deletion coming soon!',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
