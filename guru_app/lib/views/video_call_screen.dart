import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/call_controller.dart';
import 'package:guru_app/theme/theme.dart';
import 'package:guru_app/widgets/widgets.dart';

class VideoCallScreen extends StatefulWidget {
  final String requestId;

  const VideoCallScreen({Key? key, required this.requestId}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _call = Get.find<CallController>();
  final _ratingController = TextEditingController();
  final _selectedRating = 5.obs;

  @override
  void initState() {
    super.initState();
    _call.joinRoom(widget.requestId);
  }

  void _showRatingSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.s24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.s24),
            topRight: Radius.circular(AppSpacing.s24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Rate Your Session with Aarav',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              AppSpacing.v12,
              const Text(
                'How was your macros and form check review?',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
              ),
              AppSpacing.v16,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (idx) {
                  return Obx(() {
                    final rating = idx + 1;
                    final isSelected = rating <= _selectedRating.value;
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: isSelected ? Colors.amber : Colors.grey.shade300,
                        size: 36,
                      ),
                      onPressed: () => _selectedRating.value = rating,
                    );
                  });
                }),
              ),
              AppSpacing.v16,
              AppTextField(
                labelText: 'Session Review & Comments (Optional)',
                hintText: 'Great feedback on my deadlift alignment!',
                controller: _ratingController,
              ),
              AppSpacing.v24,
              PrimaryButton(
                text: 'Save Feedback',
                onPressed: () {
                  _call.submitSessionRating(_ratingController.text, _selectedRating.value);
                  Get.back(); // close sheet
                  Get.back(); // close video screen
                },
              ),
            ],
          ),
        ),
      ),
      isDismissible: false,
    );
  }

  String _formatDuration(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    // Listen for call terminated by trainer peer
    ever(_call.peerState, (state) {
      if (state == 'ended' && mounted) {
        _showRatingSheet();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video grid (2 tiles)
            Obx(() {
              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // Participant 1: Aarav
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: _call.peerState.value == 'in-call'
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&q=80&w=600',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey.shade900,
                                        child: const Icon(Icons.person, size: 64, color: Colors.white54),
                                      ),
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                                        ),
                                        AppSpacing.v12,
                                        const Text(
                                          'Waiting for Aarav to join...',
                                          style: TextStyle(color: Colors.white54, fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Aarav (Lead Trainer)',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        // Participant 2: DK (You)
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: _call.isCamOn.value
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=600',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey.shade900,
                                        child: const Icon(Icons.person, size: 64, color: Colors.white54),
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'DK (You) • Camera Off',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DK (Member)',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),

            // Call overlay metrics
            Positioned(
              top: 16,
              left: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Obx(() => Text(
                          _formatDuration(_call.durationSec.value),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        )),
                  ),
                  AppSpacing.h8,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      '100ms Active',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // Controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: _call.isMicOn.value ? Colors.white24 : Colors.red,
                      radius: 26,
                      child: IconButton(
                        icon: Icon(_call.isMicOn.value ? Icons.mic : Icons.mic_off, color: Colors.white),
                        onPressed: _call.toggleMic,
                      ),
                    ),
                    AppSpacing.h16,
                    CircleAvatar(
                      backgroundColor: _call.isCamOn.value ? Colors.white24 : Colors.red,
                      radius: 26,
                      child: IconButton(
                        icon: Icon(_call.isCamOn.value ? Icons.videocam : Icons.videocam_off, color: Colors.white),
                        onPressed: _call.toggleCam,
                      ),
                    ),
                    AppSpacing.h16,
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 26,
                      child: IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                        onPressed: _call.flipCamera,
                      ),
                    ),
                    AppSpacing.h24,
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 30,
                      child: IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.white, size: 28),
                        onPressed: () {
                          _call.leaveRoom(widget.requestId);
                          _showRatingSheet();
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
