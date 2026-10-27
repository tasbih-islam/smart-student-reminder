import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';

// সব task এর তালিকা, উপরে type অনুযায়ী filter
class AllTasksTab extends StatefulWidget {
  final List<Task> tasks;
  final void Function(Task) onToggle;
  final void Function(Task) onEdit;
  final void Function(Task) onDelete;

  const AllTasksTab({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<AllTasksTab> createState() => _AllTasksTabState();
}

class _AllTasksTabState extends State<AllTasksTab> {
  String _filter = 'All';
  final _filters = ['All', 'Assignment', 'Exam', 'Class'];

  @override
  Widget build(BuildContext context) {
    final list = _filter == 'All'
        ? widget.tasks
        : widget.tasks.where((t) => t.type == _filter).toList();

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: _filters
                .map((f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              ),
            ))
                .toList(),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(
            child: Text('No tasks here yet.',
                style: TextStyle(color: Colors.black54)),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final t = list[i];
              return TaskCard(
                task: t,
                onTap: () => widget.onEdit(t),
                onToggle: () => widget.onToggle(t),
                onDelete: () => widget.onDelete(t),
              );
            },
          ),
        ),
      ],
    );
  }
}