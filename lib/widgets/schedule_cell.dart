import 'package:flutter/material.dart';
import '../week_schedule_view.dart';

class ScheduleCell extends StatelessWidget {
  final ScheduleItem? schedule;
  final VoidCallback onTap;

  const ScheduleCell({
    super.key,
    this.schedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: schedule != null
              ? Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: schedule!.isFirst 
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      schedule!.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: schedule!.isFirst ? Colors.blue[800] : Colors.grey[600],
                        fontWeight: schedule!.isFirst ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
