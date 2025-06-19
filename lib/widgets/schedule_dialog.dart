import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';

class ScheduleDialog extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final String initialCustomer;
  final String? initialTitle;
  final List<String> customers;
  final Function(List<DateTime> dates, String customer, String title) onSave;
  final VoidCallback? onDelete;

  const ScheduleDialog({
    super.key,
    required this.title,
    required this.initialDate,
    required this.initialCustomer,
    this.initialTitle,
    required this.customers,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  late TextEditingController _titleController;
  late String _selectedCustomer;
  List<DateTime> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedCustomer = widget.initialCustomer;
    _selectedDates = widget.initialTitle != null ? [widget.initialDate] : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showRoundedDatePicker(
      context: context,
      initialDate: _selectedDates.isNotEmpty ? _selectedDates.first : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ja', 'JP'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      styleDatePicker: MaterialRoundedDatePickerStyle(
        textStyleYearButton: const TextStyle(
          fontSize: 52,
          color: Colors.white,
        ),
        textStyleDayButton: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        textStyleCurrentDayOnCalendar: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    if (picked != null) {
      setState(() {
        if (_selectedDates.contains(picked)) {
          _selectedDates.remove(picked);
        } else {
          _selectedDates.add(picked);
        }
        _selectedDates.sort();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('日付'),
            subtitle: _selectedDates.isEmpty 
                ? const Text('日付を選択してください')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('選択された日付: ${_selectedDates.length}日'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: _selectedDates.map((date) {
                          final isFirst = _selectedDates.first == date;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isFirst ? Colors.blue : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${date.month}/${date.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectDate,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'タイトル',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCustomer,
            decoration: const InputDecoration(
              labelText: '客先',
            ),
            items: widget.customers.map((customer) {
              return DropdownMenuItem(
                value: customer,
                child: Text(customer),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCustomer = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        if (widget.onDelete != null)
          TextButton(
            onPressed: () {
              widget.onDelete!();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty && _selectedDates.isNotEmpty) {
              widget.onSave(_selectedDates, _selectedCustomer, _titleController.text);
              Navigator.pop(context);
            }
          },
          child: Text(widget.initialTitle != null ? '保存' : '追加'),
        ),
      ],
    );
  }
}