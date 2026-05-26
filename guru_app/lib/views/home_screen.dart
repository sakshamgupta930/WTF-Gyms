import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/storage_controller.dart';
import '../controllers/socket_controller.dart';
import 'chat_screen.dart';
import 'schedule_call_screen.dart';
import 'video_call_screen.dart';
import 'dev_panel.dart';
import 'package:guru_app/theme/theme.dart';
import 'package:guru_app/widgets/widgets.dart';
import 'package:guru_app/models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0.obs;

  final _storage = Get.find<StorageController>();
  final _socket = Get.find<SocketController>();

  final _selectedFilter = 'All'.obs; // 'All', 'Last 7 Days', 'This Month'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Guru Dashboard',
        subtitle: 'Coach: Aarav (Lead)',
        badgeText: 'Member • DK',
        badgeColor: AppColors.guruPrimary,
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _socket.isConnected.value ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: _socket.isConnected.value ? AppColors.success : AppColors.error,
                    ),
                    AppSpacing.h4,
                    Text(
                      _socket.isConnected.value ? 'Synced' : 'Connecting...',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _socket.isConnected.value ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              )),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondaryLight),
            onPressed: () {
              _storage.clearAll();
              Get.snackbar(
                'Data Cleared',
                'All local storage cache has been reset',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.guruPrimary,
                colorText: Colors.white,
              );
            },
            tooltip: 'Wipe Cache & Reset',
          ),
        ],
      ),
      body: Obx(() {
        switch (_currentIndex.value) {
          case 0:
            return _buildDashboardTab();
          case 1:
            return _buildSessionsTab();
          default:
            return _buildDashboardTab();
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const DevPanel()),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        tooltip: 'Open DevPanel',
        mini: true,
        child: const Text('⋮', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: _currentIndex.value,
            onTap: (index) => _currentIndex.value = index,
            selectedItemColor: AppColors.guruPrimary,
            unselectedItemColor: AppColors.textSecondaryLight,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Session Logs'),
            ],
          )),
    );
  }

  // ==================== DASHBOARD TAB ====================
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Welcome Card
            _buildWelcomeCard(),
            AppSpacing.v24,

            // Section: Upcoming Calls
            const Text(
              'UPCOMING SESSIONS & CALLS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
            AppSpacing.v8,
            Obx(() {
              final upcoming = _storage.requests.where((e) => e.status == 'approved').toList();

              if (upcoming.isEmpty) {
                return _buildDashboardCardPlaceholder(
                  'No upcoming sessions',
                  'Approved call requests will show here with a Join link.',
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcoming.length,
                itemBuilder: (context, idx) {
                  final req = upcoming[idx];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.s8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.guruPrimaryLight,
                          child: Icon(Icons.videocam, color: AppColors.guruPrimary),
                        ),
                        AppSpacing.h12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Weekly Check-in Call', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              AppSpacing.v4,
                              Text(
                                '${_formatDateTime(req.scheduledFor)}',
                                style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        PrimaryButton(
                          text: 'Join',
                          type: ButtonType.filled,
                          color: AppColors.success,
                          onPressed: () {
                            Get.to(() => VideoCallScreen(requestId: req.id));
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
            AppSpacing.v24,

            // Section: Core Dashboard Actions (The 3 required cards)
            const Text(
              'YOUR PARTNER ECOSYSTEM',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
            AppSpacing.v8,
            _buildActionCard(
              'Chat with Trainer',
              'Check food reviews & adjust macros',
              Icons.chat_bubble_outline,
              AppColors.guruPrimary,
              () => Get.to(() => const ChatScreen()),
            ),
            AppSpacing.v12,
            _buildActionCard(
              'Schedule Call',
              'Book time slots with Coach Aarav',
              Icons.calendar_today_rounded,
              AppColors.warning,
              () => Get.to(() => const ScheduleCallScreen()),
            ),
            AppSpacing.v12,
            _buildActionCard(
              'My Sessions',
              'Check ratings and diagnostic logs',
              Icons.assessment_outlined,
              AppColors.success,
              () => _currentIndex.value = 1, // navigate to Sessions tab
            ),

            AppSpacing.v24,
            const Text(
              'MY PENDING REQUESTS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
            AppSpacing.v8,
            Obx(() {
              final pending = _storage.requests.where((e) => e.status == 'pending').toList();

              if (pending.isEmpty) {
                return _buildDashboardCardPlaceholder(
                  'No pending requests',
                  'When you schedule a call, requests will display here.',
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pending.length,
                itemBuilder: (context, idx) {
                  final req = pending[idx];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.s8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFF7ED),
                          child: Icon(Icons.history_toggle_off, color: AppColors.warning),
                        ),
                        AppSpacing.h12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(req.note.isEmpty ? 'Macro & Form Review' : req.note, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              AppSpacing.v4,
                              Text(
                                '${_formatDateTime(req.scheduledFor)}',
                                style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const StatusChip(status: 'pending'),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final user = _storage.currentUser.value;
    final uName = user?.name ?? 'DK';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.guruPrimary,
            Color(0xFF2E82FF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.s16),
        boxShadow: [
          BoxShadow(
            color: AppColors.guruPrimary.withOpacity(0.2),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                radius: 20,
                backgroundColor: Colors.white24,
                child: user?.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              AppSpacing.h12,
              Expanded(
                child: Text(
                  'Hello, $uName 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          AppSpacing.v16,
          const Text(
            'Keep pushing hard on your fitness targets today. Your coach Aarav is synced and ready to review your logs!',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }

  Widget _buildDashboardCardPlaceholder(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSpacing.s12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.event_note, color: Colors.grey.shade300, size: 30),
          AppSpacing.v8,
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
          AppSpacing.v4,
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ==================== SESSIONS TAB ====================
  Widget _buildSessionsTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _buildFilterChip('All'),
              AppSpacing.h8,
              _buildFilterChip('Last 7 Days'),
              AppSpacing.h8,
              _buildFilterChip('This Month'),
            ],
          ),
          AppSpacing.v16,
          Expanded(
            child: Obx(() {
              List<SessionLogModel> filtered = List<SessionLogModel>.from(_storage.sessionLogs);

              if (_selectedFilter.value == 'Last 7 Days') {
                final cutoff = DateTime.now().subtract(const Duration(days: 7));
                filtered = filtered.where((e) => e.endedAt.isAfter(cutoff)).toList();
              } else if (_selectedFilter.value == 'This Month') {
                final now = DateTime.now();
                filtered = filtered.where((e) => e.endedAt.month == now.month && e.endedAt.year == now.year).toList();
              }

              if (filtered.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.assignment_outlined,
                  title: 'No sessions completed yet',
                  description: 'Schedule your first call to record diagnostic reviews.',
                );
              }

              final sorted = List<SessionLogModel>.from(filtered)..sort((a, b) => b.endedAt.compareTo(a.endedAt));

              return ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (context, idx) {
                  final log = sorted[idx];
                  return AppCard(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    onTap: () => _showSessionDetailsModal(log),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: const Icon(Icons.done, color: AppColors.success),
                        ),
                        AppSpacing.h16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Session with Coach Aarav', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              AppSpacing.v4,
                              Text(
                                '${_formatDateTime(log.endedAt)} • ${_formatDuration(log.durationSec)}',
                                style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (log.rating != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              AppSpacing.h4,
                              Text('${log.rating}★', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          )
                        ],
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Obx(() {
      final isSelected = _selectedFilter.value == label;
      return ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
        selected: isSelected,
        onSelected: (val) => _selectedFilter.value = label,
        selectedColor: AppColors.guruPrimary,
        backgroundColor: Colors.grey.shade100,
        side: BorderSide.none,
      );
    });
  }

  void _showSessionDetailsModal(SessionLogModel log) {
    Get.dialog(
      AlertDialog(
        title: const Text('Session Diagnostic Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coach: Aarav (Lead)', style: const TextStyle(fontWeight: FontWeight.bold)),
            AppSpacing.v8,
            Text('Date: ${_formatDateTime(log.endedAt)}', style: const TextStyle(fontSize: 13)),
            Text('Duration: ${_formatDuration(log.durationSec)}', style: const TextStyle(fontSize: 13)),
            if (log.rating != null) ...[
              AppSpacing.v8,
              Row(
                children: [
                  const Text('Your Rating: ', style: TextStyle(fontSize: 13)),
                  ...List.generate(5, (index) => Icon(Icons.star, color: index < log.rating! ? Colors.amber : Colors.grey.shade300, size: 14)),
                ],
              )
            ],
            AppSpacing.v16,
            const Text('Coach Feedback Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            AppSpacing.v4,
            Text(log.trainerNotes ?? 'No notes recorded.', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            if (log.memberNotes != null && log.memberNotes!.isNotEmpty) ...[
              AppSpacing.v12,
              const Text('Your Comments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              AppSpacing.v4,
              Text(log.memberNotes!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            ]
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Get.back(),
          )
        ],
      ),
    );
  }

  // ==================== TIME FORMATTERS ====================
  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  String _formatDuration(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m}m ${s}s';
  }
}
