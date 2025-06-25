import 'package:flutter/material.dart';
import 'schedule_cell.dart';
import '../week_schedule_view.dart';

class ScheduleGrid extends StatelessWidget {
  final List<DateTime> days;
  final List<String> customers;
  final Map<DateTime, Map<String, List<ScheduleItem>>> schedules;
  final DateTime selectedDay;
  final List<String> weekdays;
  final Function(DateTime) onDateTap;
  final Function(DateTime, String, int?) onScheduleTap;

  const ScheduleGrid({
    super.key,
    required this.days,
    required this.customers,
    required this.schedules,
    required this.selectedDay,
    required this.weekdays,
    required this.onDateTap,
    required this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final date = days[dayIndex];
        final isSelected = DateUtils.isSameDay(date, selectedDay);
        
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              _buildDateCell(date, isSelected),
              ...customers.map((customer) {
                final scheduleList = schedules[date]?[customer];
                return ScheduleCell(
                  schedules: scheduleList,
                  onScheduleTap: (index) => onScheduleTap(date, customer, index),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateCell(DateTime date, bool isSelected) {
    return SizedBox(
      width: 80,
      child: GestureDetector(
        onTap: () => onDateTap(date),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.month}/${date.day}',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '(${weekdays[date.weekday - 1]})',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
