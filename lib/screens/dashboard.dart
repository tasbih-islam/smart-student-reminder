import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/task_card.dart';

// Dashboard: আজকের ও আসন্ন task দেখায়
class DashboardTab extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task) onToggle;
  final void Function(Task) onEdit;
  final void Function(Task) onDelete;
  final VoidCallback onLogout;

  const DashboardTab({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onLogout,
  });

  Widget _stat(String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text('$count',
                style: const TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  List<Widget> _section(String title, List<Task> list, String empty) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      if (list.isEmpty)
        Text(empty, style: const TextStyle(color: Colors.black54))
      else
        ...list.map((t) => TaskCard(
          task: t,
          onTap: () => onEdit(t),
          onToggle: () => onToggle(t),
          onDelete: () => onDelete(t),
        )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final startTomorrow = DateTime(now.year, now.month, now.day + 1);

    final pending = tasks.where((t) => !t.done).toList();
    final today = pending.where((t) => isSameDay(t.dueAt, now)).toList();
    final upcoming = pending.where((t) => !t.dueAt.isBefore(startTomorrow)).toList();
    final overdue = pending.where((t) => t.dueAt.isBefore(startToday)).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // উপরের রঙিন header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${AuthService.currentUserName} 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(formatDate(now),
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _stat('Today', today.length),
                  const SizedBox(width: 10),
                  _stat('Upcoming', upcoming.length),
                  const SizedBox(width: 10),
                  _stat('Overdue', overdue.length),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overdue.isNotEmpty) ..._section('Overdue', overdue, ''),
              ..._section('Today', today, 'Nothing due today 🎉'),
              ..._section('Upcoming', upcoming, 'No upcoming tasks. Tap "Add Task".'),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 16, color: Colors.black38),
                  SizedBox(width: 6),
                  Text('Saved on your device. Works without internet.',
                      style: TextStyle(color: Colors.black38, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}