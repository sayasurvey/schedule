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
  
  // 客先名のリスト
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

  // スケジュールデータを管理するMap
  final Map<DateTime, Map<String, String>> _schedules = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  // 月の日数を取得
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // 月の日付リストを取得
  List<DateTime> _getDaysInMonthList(DateTime date) {
    final daysInMonth = _getDaysInMonth(date);
    return List.generate(daysInMonth, (index) {
      return DateTime(date.year, date.month, index + 1);
    });
  }

  // スケジュールを追加するメソッド
  void _addSchedule(DateTime date, String customer, String title) {
    setState(() {
      if (!_schedules.containsKey(date)) {
        _schedules[date] = {};
      }
      _schedules[date]![customer] = title;
    });
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
          _buildCustomerHeader(),
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
    String selectedCustomer = _customers[0];

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
                value: selectedCustomer,
                items: _customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCustomer = value;
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
                  _addSchedule(_selectedDay, selectedCustomer, titleController.text);
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

  Widget _buildCustomerHeader() {
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
          ..._customers.map((customer) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Center(
                  child: Text(
                    customer,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
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
    final days = _getDaysInMonthList(_focusedDay);

    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final date = days[dayIndex];
        final isSelected = DateUtils.isSameDay(date, _selectedDay);
        
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
              ),
              ..._customers.map((customer) {
                final schedule = _schedules[date]?[customer];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (schedule != null) {
                        // 既存のスケジュールを編集
                        _showEditScheduleDialog(date, customer, schedule);
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
  void _showEditScheduleDialog(DateTime date, String customer, String currentTitle) {
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
                  _addSchedule(date, customer, titleController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _schedules[date]?.remove(customer);
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