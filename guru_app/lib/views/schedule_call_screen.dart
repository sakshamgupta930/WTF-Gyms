import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/request_controller.dart';
import 'package:guru_app/theme/theme.dart';
import 'package:guru_app/widgets/widgets.dart';

class ScheduleCallScreen extends StatefulWidget {
  const ScheduleCallScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleCallScreen> createState() => _ScheduleCallScreenState();
}

class _ScheduleCallScreenState extends State<ScheduleCallScreen> {
  final _request = Get.find<RequestController>();
  final _noteController = TextEditingController();

  final _selectedDayIndex = 0.obs;
  final _selectedTimeIndex = (-1).obs;

  late List<DateTime> _days;
  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '06:00 PM',
    '07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _days = [
      today,
      today.add(const Duration(days: 1)),
      today.add(const Duration(days: 2)),
    ];
  }

  void _submitRequest() {
    if (_selectedTimeIndex.value == -1) {
      Get.snackbar(
        'Selection Required',
        'Please pick a time slot first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final day = _days[_selectedDayIndex.value];
    final slotString = _timeSlots[_selectedTimeIndex.value];

    final parts = slotString.split(' ');
    final timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final period = parts[1];

    if (period == 'PM' && hour < 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final selectedDateTime = DateTime(day.year, day.month, day.day, hour, minute);

    if (_noteController.text.length > 140) {
      Get.snackbar(
        'Validation Error',
        'Note must be less than 140 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final success = _request.createCallRequest(selectedDateTime, _noteController.text);

    if (success) {
      Get.back();
      Get.snackbar(
        'Request Sent',
        'Call requested. Waiting for trainer approval.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Conflict Detected',
        'This slot has already been booked. Please pick another!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Schedule a Call',
        subtitle: 'Request slots with Aarav',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'SELECT DATE (NEXT 3 DAYS)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
                ),
                AppSpacing.v12,
                _buildDaySelector(),
                AppSpacing.v24,
                const Text(
                  'AVAILABLE TIME SLOTS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
                ),
                AppSpacing.v12,
                _buildTimeSlotsGrid(),
                AppSpacing.v24,
                AppTextField(
                  labelText: 'Session Focus Note (Max 140 chars)',
                  hintText: 'E.g. Squat form check & review macro targets...',
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 140,
                ),
                AppSpacing.v32,
                PrimaryButton(
                  text: 'Request Call',
                  onPressed: _submitRequest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_days.length, (idx) {
        final day = _days[idx];
        final dayLabel = idx == 0 ? 'Today' : (idx == 1 ? 'Tomorrow' : _formatDay(day));
        return Expanded(
          child: Obx(() {
            final isSelected = _selectedDayIndex.value == idx;
            return GestureDetector(
              onTap: () {
                _selectedDayIndex.value = idx;
                _selectedTimeIndex.value = -1;
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.guruPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.s8),
                  border: Border.all(color: isSelected ? AppColors.guruPrimary : Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}/${day.month}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white70 : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildTimeSlotsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, idx) {
        final slot = _timeSlots[idx];
        return Obx(() {
          final isSelected = _selectedTimeIndex.value == idx;
          return ChoiceChip(
            label: Text(
              slot,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.guruPrimary,
            backgroundColor: Colors.white,
            side: BorderSide(color: isSelected ? AppColors.guruPrimary : Colors.grey.shade200),
            onSelected: (val) {
              if (val) _selectedTimeIndex.value = idx;
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.s8)),
          );
        });
      },
    );
  }

  String _formatDay(DateTime dt) {
    switch (dt.weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}
