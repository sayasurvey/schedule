import 'package:flutter/material.dart';
import 'widgets/customer_header.dart';
import 'widgets/schedule_grid.dart';
import 'widgets/schedule_dialog.dart';

class ScheduleItem {
  final String title;
  final bool isFirst;

  ScheduleItem({required this.title, required this.isFirst});
}

class WeekScheduleView extends StatefulWidget {
  const WeekScheduleView({super.key});

  @override
  State<WeekScheduleView> createState() => _WeekScheduleViewState();
}

class _WeekScheduleViewState extends State<WeekScheduleView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  
  final List<String> _customers = [
    'Amazon',
    '楽天',
    'ZOZO',
    'メルカリ',
    'suzuri',
    'BASE',
    'Qoo10',
    'アットコスメ'
  ];

  final Map<DateTime, Map<String, List<ScheduleItem>>> _schedules = {};
  final List<String> _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  List<DateTime> _getDaysInMonthList(DateTime date) {
    final daysInMonth = _getDaysInMonth(date);
    return List.generate(daysInMonth, (index) {
      return DateTime(date.year, date.month, index + 1);
    });
  }

  void _addMultipleSchedules(List<DateTime> dates, String customer, String title) {
    setState(() {
      for (int i = 0; i < dates.length; i++) {
        final date = dates[i];
        if (!_schedules.containsKey(date)) {
          _schedules[date] = {};
        }
        if (!_schedules[date]!.containsKey(customer)) {
          _schedules[date]![customer] = [];
        }
        final isFirst = i == 0;
        _schedules[date]![customer]!.add(ScheduleItem(title: title, isFirst: isFirst));
      }
    });
  }

  void _removeSchedule(DateTime date, String customer, int index) {
    setState(() {
      _schedules[date]?[customer]?.removeAt(index);
      if (_schedules[date]?[customer]?.isEmpty ?? false) {
        _schedules[date]?.remove(customer);
      }
    });
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        title: 'スケジュールを追加',
        initialDate: _selectedDay,
        initialCustomer: _customers[0],
        customers: _customers,
        onSave: _addMultipleSchedules,
      ),
    );
  }

  void _showAddScheduleDialogForCell(DateTime date, String customer) {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        title: 'スケジュールを追加',
        initialDate: date,
        initialCustomer: customer,
        customers: _customers,
        onSave: _addMultipleSchedules,
      ),
    );
  }

  void _showEditScheduleDialog(DateTime date, String customer, String currentTitle, int index) {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        title: 'スケジュールを編集',
        initialDate: date,
        initialCustomer: customer,
        initialTitle: currentTitle,
        customers: _customers,
        onSave: (newDates, newCustomer, newTitle) {
          _removeSchedule(date, customer, index);
          _addMultipleSchedules(newDates, newCustomer, newTitle);
        },
        onDelete: () => _removeSchedule(date, customer, index),
      ),
    );
  }

  void _onDateTap(DateTime date) {
    setState(() {
      _selectedDay = date;
    });
  }

  void _onScheduleTap(DateTime date, String customer, List<ScheduleItem>? schedules) {
    if (schedules != null && schedules.isNotEmpty) {
      // If there's only one schedule, edit it directly
      if (schedules.length == 1) {
        _showEditScheduleDialog(date, customer, schedules[0].title, 0);
      } else {
        // Show selection dialog for multiple schedules
        _showScheduleSelectionDialog(date, customer, schedules);
      }
    } else {
      _showAddScheduleDialogForCell(date, customer);
    }
  }

  void _showScheduleSelectionDialog(DateTime date, String customer, List<ScheduleItem> schedules) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スケジュールを選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...schedules.asMap().entries.map((entry) {
              final index = entry.key;
              final schedule = entry.value;
              return ListTile(
                title: Text(schedule.title),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showEditScheduleDialog(date, customer, schedule.title, index);
                  },
                ),
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('新しいスケジュールを追加'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddScheduleDialogForCell(date, customer);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_focusedDay.year}年${_focusedDay.month}月のスケジュール'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CustomerHeader(customers: _customers),
          Expanded(
            child: ScheduleGrid(
              days: _getDaysInMonthList(_focusedDay),
              customers: _customers,
              schedules: _schedules,
              selectedDay: _selectedDay,
              weekdays: _weekdays,
              onDateTap: _onDateTap,
              onScheduleTap: _onScheduleTap,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
