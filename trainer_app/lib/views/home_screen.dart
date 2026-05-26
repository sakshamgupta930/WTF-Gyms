import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/storage_controller.dart';
import '../controllers/socket_controller.dart';
import '../controllers/request_controller.dart';
import 'chat_screen.dart';
import 'video_call_screen.dart';
import 'dev_panel.dart';
import 'package:trainer_app/theme/theme.dart';
import 'package:trainer_app/widgets/widgets.dart';
import 'package:trainer_app/models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0.obs;

  final _storage = Get.find<StorageController>();
  final _socket = Get.find<SocketController>();
  final _request = Get.find<RequestController>();

  final _declineReasonController = TextEditingController();

  final _selectedFilter = 'All'.obs; // 'All', 'Last 7 Days', 'This Month'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Trainer Portal',
        subtitle: 'Lead Coach Aarav',
        badgeText: 'Trainer • Aarav',
        badgeColor: AppColors.trainerPrimary,
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _socket.isServerRunning.value ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: _socket.isServerRunning.value ? AppColors.success : AppColors.error,
                    ),
                    AppSpacing.h4,
                    Text(
                      _socket.isServerRunning.value ? 'Synced' : 'Offline',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _socket.isServerRunning.value ? AppColors.success : AppColors.error,
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
                'Data Reset',
                'All local storage cache re-seeded successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.trainerPrimary,
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
            return _buildCrmTab();
          case 2:
            return _buildRequestsTab();
          case 3:
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
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.trainerPrimary,
            unselectedItemColor: AppColors.textSecondaryLight,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Members'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Requests'),
              BottomNavigationBarItem(icon: Icon(Icons.assessment_rounded), label: 'Sessions'),
            ],
          )),
    );
  }

  // ==================== DASHBOARD TAB ====================
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Total Members', _storage.members.length.toString(), Icons.people_outline, Colors.blue),
                ),
                AppSpacing.h12,
                Expanded(
                  child: Obx(() {
                    final pendingCount = _storage.requests.where((e) => e.status == 'pending').length;
                    return _buildMetricCard('Pending Calls', pendingCount.toString(), Icons.phone_callback_outlined, AppColors.warning);
                  }),
                ),
              ],
            ),
            AppSpacing.v12,
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final approvedCount = _storage.requests.where((e) => e.status == 'approved').length;
                    return _buildMetricCard('Upcoming Calls', approvedCount.toString(), Icons.videocam_outlined, AppColors.success);
                  }),
                ),
                AppSpacing.h12,
                Expanded(
                  child: Obx(() {
                    final logs = _storage.sessionLogs;
                    double ratingAvg = 0.0;
                    if (logs.isNotEmpty) {
                      final hasRating = logs.where((e) => e.rating != null);
                      if (hasRating.isNotEmpty) {
                        ratingAvg = hasRating.map((e) => e.rating!).reduce((a, b) => a + b) / hasRating.length;
                      }
                    }
                    return _buildMetricCard('Avg Rating', logs.isEmpty ? 'N/A' : '${ratingAvg.toStringAsFixed(1)}★', Icons.star_outline, Colors.amber);
                  }),
                ),
              ],
            ),
            AppSpacing.v24,
            const Text(
              'UPCOMING SESSIONS & CALLS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
            AppSpacing.v8,
            Obx(() {
              final upcoming = _storage.requests.where((e) => e.status == 'approved').toList();

              if (upcoming.isEmpty) {
                return _buildDashboardCardPlaceholder(
                  'No upcoming video calls',
                  'Approved call requests will populate here.',
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
                          backgroundColor: AppColors.trainerPrimaryLight,
                          child: Icon(Icons.videocam, color: AppColors.trainerPrimary),
                        ),
                        AppSpacing.h12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Call with DK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
            const Text(
              'QUICK SHORTCUTS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
            AppSpacing.v8,
            AppCard(
              onTap: () => Get.to(() => const ChatScreen()),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFEBF3FF),
                    child: Icon(Icons.chat_bubble_outline, color: AppColors.guruPrimary),
                  ),
                  AppSpacing.h16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chat with Member (DK)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('Check unread messages and reply in real-time', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondaryLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.s12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), offset: const Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          AppSpacing.v12,
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
        ],
      ),
    );
  }

  Widget _buildDashboardCardPlaceholder(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSpacing.s12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.event_note, color: Colors.grey.shade300, size: 36),
          AppSpacing.v8,
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
          AppSpacing.v4,
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ==================== MEMBERS CRM TAB ====================
  Widget _buildCrmTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Obx(() {
        final mList = _storage.members;

        if (mList.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.people_outline,
            title: 'No members assigned',
            description: 'Assigned members will show in your CRM list.',
          );
        }

        return ListView.builder(
          itemCount: mList.length,
          itemBuilder: (context, idx) {
            final u = mList[idx];
            return AppCard(
              margin: const EdgeInsets.symmetric(vertical: 6),
              onTap: () => _showMemberDetailsSheet(u),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
                    radius: 22,
                    child: u.avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                  AppSpacing.h16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(u.email, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Chip(
                    label: Text('Active Client', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                    backgroundColor: Color(0xFFECFDF3),
                    side: BorderSide.none,
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showMemberDetailsSheet(UserModel user) {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    radius: 30,
                  ),
                  AppSpacing.h16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                        Text(user.email, style: const TextStyle(color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  )
                ],
              ),
              AppSpacing.v20,
              const Divider(),
              AppSpacing.v12,
              const Text('CLIENT STATISTICS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight)),
              AppSpacing.v12,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Completed Sessions', style: TextStyle(fontSize: 14)),
                  Obx(() {
                    final count = _storage.sessionLogs.where((e) => e.memberId == user.id).length;
                    return Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold));
                  }),
                ],
              ),
              AppSpacing.v8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pending Booking Requests', style: TextStyle(fontSize: 14)),
                  Obx(() {
                    final count = _storage.requests.where((e) => e.memberId == user.id && e.status == 'pending').length;
                    return Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning));
                  }),
                ],
              ),
              AppSpacing.v24,
              PrimaryButton(
                text: 'Open Chat',
                onPressed: () {
                  Get.back(); // close sheet
                  Get.to(() => const ChatScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== REQUESTS TAB ====================
  Widget _buildRequestsTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Obx(() {
        final pReqs = _storage.requests.where((e) => e.status == 'pending').toList();

        if (pReqs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.calendar_month,
            title: 'No pending requests',
            description: 'All call scheduling requests are processed.',
          );
        }

        return ListView.builder(
          itemCount: pReqs.length,
          itemBuilder: (context, idx) {
            final req = pReqs[idx];
            return AppCard(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.trainerPrimaryLight,
                        child: Icon(Icons.phone_callback, color: AppColors.trainerPrimary),
                      ),
                      AppSpacing.h12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Call Request from DK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              'Requested: ${_formatDateTime(req.requestedAt)}',
                              style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const StatusChip(status: 'pending')
                    ],
                  ),
                  AppSpacing.v12,
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(AppSpacing.s4),
                    ),
                    child: Text(
                      '"${req.note}"',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textPrimaryLight),
                    ),
                  ),
                  AppSpacing.v12,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scheduled: ${_formatDateTime(req.scheduledFor)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimaryLight),
                      ),
                    ],
                  ),
                  AppSpacing.v16,
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Decline',
                          type: ButtonType.outline,
                          onPressed: () => _showDeclineReasonModal(req.id),
                        ),
                      ),
                      AppSpacing.h12,
                      Expanded(
                        child: PrimaryButton(
                          text: 'Approve',
                          type: ButtonType.filled,
                          onPressed: () => _request.approveRequest(req.id),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeclineReasonModal(String reqId) {
    _declineReasonController.clear();
    Get.dialog(
      AlertDialog(
        title: const Text('Decline Call Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please provide a reason why this time slot cannot be scheduled.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            AppSpacing.v12,
            AppTextField(
              labelText: 'Decline Reason',
              hintText: 'E.g. Conflict with team meeting. Pick another slot!',
              controller: _declineReasonController,
              maxLines: 2,
            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.trainerPrimary),
            child: const Text('Decline Request', style: TextStyle(color: Colors.white)),
            onPressed: () {
              final reason = _declineReasonController.text.trim().isEmpty ? 'Trainer unavailable at this time slot' : _declineReasonController.text;
              _request.declineRequest(reqId, reason);
              Get.back();
            },
          )
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
          // Filter Tabs
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
                  title: 'No sessions recorded',
                  description: 'Schedule and complete a call to populate your logs.',
                );
              }

              // Sort by latest ended session
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
                              const Text('Session with DK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
        selectedColor: AppColors.trainerPrimary,
        backgroundColor: Colors.grey.shade100,
        side: BorderSide.none,
      );
    });
  }

  void _showSessionDetailsModal(SessionLogModel log) {
    Get.dialog(
      AlertDialog(
        title: const Text('Session Diagnostics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: DK', style: const TextStyle(fontWeight: FontWeight.bold)),
            AppSpacing.v8,
            Text('Date: ${_formatDateTime(log.endedAt)}', style: const TextStyle(fontSize: 13)),
            Text('Duration: ${_formatDuration(log.durationSec)}', style: const TextStyle(fontSize: 13)),
            if (log.rating != null) ...[
              AppSpacing.v8,
              Row(
                children: [
                  const Text('Member Rating: ', style: TextStyle(fontSize: 13)),
                  ...List.generate(5, (index) => Icon(Icons.star, color: index < log.rating! ? Colors.amber : Colors.grey.shade300, size: 14)),
                ],
              )
            ],
            AppSpacing.v16,
            const Text('Trainer Logs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            AppSpacing.v4,
            Text(log.trainerNotes ?? 'No notes recorded.', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            if (log.memberNotes != null) ...[
              AppSpacing.v12,
              const Text('Member Feedback:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
