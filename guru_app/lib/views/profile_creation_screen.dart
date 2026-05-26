import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/storage_controller.dart';
import 'home_screen.dart';
import 'package:guru_app/theme/theme.dart';
import 'package:guru_app/widgets/widgets.dart';
import 'package:guru_app/models/models.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _storage = Get.find<StorageController>();
  final _nameController = TextEditingController(text: 'DK');
  final _emailController = TextEditingController(text: 'dk@wtf.fit');
  final _selectedTrainer = 'aarav_trainer'.obs;

  void _onCreateProfile() {
    if (_nameController.text.trim().isEmpty) return;
    
    final user = UserModel(
      id: 'dk_member',
      role: 'member',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_nameController.text.trim())}&background=1769E0&color=fff&size=128',
      assignedTrainerId: _selectedTrainer.value,
    );

    _storage.loginAsDK(user);
    Get.offAll(() => const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.guruPrimaryLight,
                        child: Icon(Icons.person_add_alt_1_rounded, size: 40, color: AppColors.guruPrimary),
                      ),
                    ],
                  ),
                ),
                AppSpacing.v24,
                const Text(
                  'Set up your client profile context',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.v20,
                AppTextField(
                  labelText: 'Your Name',
                  hintText: 'Enter your name...',
                  controller: _nameController,
                ),
                AppSpacing.v16,
                AppTextField(
                  labelText: 'Your Email',
                  hintText: 'Enter your email...',
                  controller: _emailController,
                ),
                AppSpacing.v16,
                const Text(
                  'Choose Your Trainer',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                ),
                AppSpacing.v8,
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.s8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: RadioListTile<String>(
                        title: const Text('Aarav (Lead Trainer)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        subtitle: const Text('Expert in macros adjustment & form checks', style: TextStyle(fontSize: 12)),
                        value: 'aarav_trainer',
                        groupValue: _selectedTrainer.value,
                        activeColor: AppColors.guruPrimary,
                        onChanged: (val) {
                          if (val != null) _selectedTrainer.value = val;
                        },
                      ),
                    )),
                AppSpacing.v32,
                PrimaryButton(
                  text: 'Create Profile',
                  onPressed: _onCreateProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
