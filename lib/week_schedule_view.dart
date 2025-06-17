import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekScheduleView extends StatefulWidget {
  const WeekScheduleView({super.key});

  @override
  State<WeekScheduleView> createState() => _WeekScheduleViewState();
}

class _WeekScheduleViewState extends State<WeekScheduleView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final List<String> _timeSlots = List.generate(
    24,
    (index) => '${index.toString().padLeft(2, '0')}:00',
  );

  // スケジュールデータを管理するMap
  final Map<DateTime, Map<String, String>> _schedules = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  // スケジュールを追加するメソッド
  void _addSchedule(DateTime date, String time, String title) {
    setState(() {
      if (!_schedules.containsKey(date)) {
        _schedules[date] = {};
      }
      _schedules[date]![time] = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('週間スケジュール'),
      ),
      body: Column(
        children: [
          _buildWeekHeader(),
          Expanded(
            child: _buildScheduleGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddScheduleDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // スケジュール追加ダイアログを表示
  void _showAddScheduleDialog() {
    final TextEditingController titleController = TextEditingController();
    String selectedTime = _timeSlots[0];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('スケジュールを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedTime,
                items: _timeSlots.map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedTime = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _addSchedule(_selectedDay, selectedTime, titleController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekHeader() {
    final days = List.generate(7, (index) {
      final date = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1 - index));
      return date;
    });

    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          ...days.map((date) {
            final isSelected = DateUtils.isSameDay(date, _selectedDay);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleGrid() {
    final days = List.generate(7, (index) {
      return _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1 - index));
    });

    return ListView.builder(
      itemCount: _timeSlots.length,
      itemBuilder: (context, timeIndex) {
        final time = _timeSlots[timeIndex];
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      time,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              ...days.map((date) {
                final schedule = _schedules[date]?[time];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (schedule != null) {
                        // 既存のスケジュールを編集
                        _showEditScheduleDialog(date, time, schedule);
                      } else {
                        // 新しいスケジュールを追加
                        _showAddScheduleDialog();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: schedule != null
                          ? Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                schedule,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // スケジュール編集ダイアログを表示
  void _showEditScheduleDialog(DateTime date, String time, String currentTitle) {
    final TextEditingController titleController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('スケジュールを編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _addSchedule(date, time, titleController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _schedules[date]?.remove(time);
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
} 