import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_profile.dart';
import '../../auth/provider/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _shopNameController;
  late TextEditingController _addressController;
  late TextEditingController _gstController;


  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    
    _mobileController = TextEditingController(text: profile?.mobile ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _shopNameController = TextEditingController(text: profile?.shopName ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
    _gstController = TextEditingController(text: profile?.gst ?? '');

  }

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final request = UpdateProfileRequest(
        mobile: _mobileController.text,
        email: _emailController.text,
        fullName: _fullNameController.text,
        shopName: _shopNameController.text,
        address: _addressController.text,
        gst: _gstController.text,
        isActive: true,
      );

      final serverMessage = await ref.read(profileProvider.notifier).updateProfile(request);

      if (serverMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(serverMessage)),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(profileProvider).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Failed to update profile')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
     final isLoading = ref.watch(profileProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || !value.contains('@') ? 'Invalid Email' : null,
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(labelText: 'GST Number'),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
