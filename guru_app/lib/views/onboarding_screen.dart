import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/storage_controller.dart';
import 'profile_creation_screen.dart';
import 'package:guru_app/theme/theme.dart';
import 'package:guru_app/widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _storage = Get.find<StorageController>();
  var _currentPage = 0.obs;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Welcome to Guru Pulse',
      'subtitle': 'Your professional coaching companion',
      'desc': 'Reaching your fitness goals starts with elite communication. Connect directly, share food logs, and optimize your routines.',
      'image': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&q=80&w=600',
    },
    {
      'title': 'Connect in Real-Time',
      'subtitle': 'Schedule calls & chat with Aarav',
      'desc': 'Get instant answers to macros adjustments, schedule weekly check-in slots, and join interactive 100ms video rooms.',
      'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&q=80&w=600',
    }
  ];

  void _onNext() {
    if (_currentPage.value < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      _storage.completeOnboarding();
      Get.off(() => const ProfileCreationScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => _currentPage.value = idx,
                itemCount: _slides.length,
                itemBuilder: (context, idx) {
                  final slide = _slides[idx];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.s12),
                           child: Image.network(
                            slide['image']!,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 240,
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.fitness_center, size: 64, color: AppColors.guruPrimary),
                            ),
                          ),
                        ),
                        AppSpacing.v32,
                        Text(
                          slide['title']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.v8,
                        Text(
                          slide['subtitle']!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.guruPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.v16,
                        Text(
                          slide['desc']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => Obx(() => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage.value == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage.value == index ? AppColors.guruPrimary : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )),
                    ),
                  ),
                  AppSpacing.v24,
                  Obx(() => PrimaryButton(
                        text: _currentPage.value == _slides.length - 1 ? 'Get Started' : 'Next',
                        onPressed: _onNext,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
