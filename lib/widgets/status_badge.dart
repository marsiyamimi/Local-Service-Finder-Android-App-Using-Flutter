import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    IconData icon;

    switch (status) {
      case BookingStatus.pending:
        color = AppColors.pending;
        bgColor = AppColors.pending.withOpacity(0.12);
        icon = Icons.schedule_rounded;
        break;
      case BookingStatus.accepted:
        color = AppColors.accepted;
        bgColor = AppColors.accepted.withOpacity(0.12);
        icon = Icons.check_circle_rounded;
        break;
      case BookingStatus.completed:
        color = AppColors.completed;
        bgColor = AppColors.completed.withOpacity(0.12);
        icon = Icons.task_alt_rounded;
        break;
      case BookingStatus.rejected:
        color = AppColors.rejected;
        bgColor = AppColors.rejected.withOpacity(0.12);
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
