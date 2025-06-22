import 'package:flutter/material.dart';
import '../week_schedule_view.dart';

class ScheduleCell extends StatelessWidget {
  final List<ScheduleItem>? schedules;
  final Function(int?) onScheduleTap;

  const ScheduleCell({
    super.key,
    this.schedules,
    required this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: schedules != null && schedules!.isNotEmpty
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      children: schedules!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final schedule = entry.value;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onScheduleTap(index),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              margin: EdgeInsets.only(
                                bottom: index < schedules!.length - 1 ? 1 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: schedule.isFirst 
                                    ? Colors.blue.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Center(
                                child: Text(
                                  schedule.title,
                                  style: TextStyle(
                                    fontSize: schedules!.length > 1 ? 10 : 12,
                                    color: schedule.isFirst ? Colors.blue[800] : Colors.grey[600],
                                    fontWeight: schedule.isFirst ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  maxLines: schedules!.length > 2 ? 1 : 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (schedules!.length > 1)
                    Container(
                      width: 20,
                      child: GestureDetector(
                        onTap: () => onScheduleTap(null),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : GestureDetector(
                onTap: () => onScheduleTap(null),
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ),
    );
  }
}
