import 'package:flutter/material.dart';
import '../theme/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String labelText = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = AppColors.warning.withOpacity(0.12);
        textColor = AppColors.warning;
        labelText = 'Pending';
        break;
      case 'approved':
        bgColor = AppColors.success.withOpacity(0.12);
        textColor = AppColors.success;
        labelText = 'Approved';
        break;
      case 'declined':
        bgColor = AppColors.error.withOpacity(0.12);
        textColor = AppColors.error;
        labelText = 'Declined';
        break;
      case 'cancelled':
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        labelText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
