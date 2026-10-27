import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/app_text_field.dart';

// নতুন task যোগ করা বা পুরনো task edit করার পেজ
class AddTaskScreen extends StatefulWidget {
  final Task? task; // null হলে নতুন, না হলে edit
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;

  final _types = ['Assignment', 'Exam', 'Class'];
  final Map<int, String> _remindOptions = {
    0: 'At due time',
    10: '10 min before',
    30: '30 min before',
    60: '1 hour before',
    1440: '1 day before',
  };

  String _type = 'Assignment';
  DateTime _due = DateTime.now();
  int _remind = 30;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _desc = TextEditingController(text: t?.description ?? '');
    if (t != null) {
      _type = t.type;
      _due = t.dueAt;
      _remind = t.remindBefore;
    } else {
      final n = DateTime.now();
      _due = DateTime(n.year, n.month, n.day, n.hour + 1); // এখন থেকে ১ ঘণ্টা পর
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() => _due = DateTime(d.year, d.month, d.day, _due.hour, _due.minute));
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_due),
    );
    if (t != null) {
      setState(() => _due = DateTime(_due.year, _due.month, _due.day, t.hour, t.minute));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final task = Task(
      id: widget.task?.id,
      userId: AuthService.currentUserId!,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      type: _type,
      dueAt: _due,
      remindBefore: _remind,
      done: widget.task?.done ?? false,
    );

    if (widget.task == null) {
      task.id = await DatabaseService.instance.insertTask(task);
    } else {
      await DatabaseService.instance.updateTask(task);
    }
    await NotificationService.schedule(task); // alert সেট

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final reminderTime = _due.subtract(Duration(minutes: _remind));
    final passed = reminderTime.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _title,
                label: 'Title (e.g. Physics assignment)',
                icon: Icons.title,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _desc,
                label: 'Notes (optional)',
                icon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text('Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _types
                    .map((t) => ChoiceChip(
                  avatar: Icon(typeIcon(t), size: 18, color: typeColor(t)),
                  label: Text(t),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              const Text('Date & Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(formatDate(_due)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(formatTime(_due)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Remind me',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _remindOptions.entries
                    .map((e) => ChoiceChip(
                  label: Text(e.value),
                  selected: _remind == e.key,
                  onSelected: (_) => setState(() => _remind = e.key),
                ))
                    .toList(),
              ),
              if (passed)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'This reminder time has already passed, so no alert will be sent.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(widget.task == null ? 'Save Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}