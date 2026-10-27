import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../theme.dart';
import 'add_task.dart';
import 'all_tasks.dart';
import 'dashboard.dart';
import 'login.dart';

// মূল পেজ: নিচে দুইটা ট্যাব (Dashboard ও All Tasks) আর একটা Add বাটন
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load(reschedule: true);
  }

  // ডাটাবেস থেকে task আনা
  Future<void> _load({bool reschedule = false}) async {
    final list = await DatabaseService.instance.getTasks(AuthService.currentUserId!);
    if (reschedule) await NotificationService.rescheduleAll(list);
    if (!mounted) return;
    setState(() {
      _tasks = list;
      _loading = false;
    });
  }

  // Done / Undone করা
  Future<void> _toggle(Task t) async {
    t.done = !t.done;
    await DatabaseService.instance.updateTask(t);
    await NotificationService.schedule(t);
    _load();
  }

  // Delete করা (আগে জিজ্ঞেস করে)
  Future<void> _delete(Task t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${t.title}" will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await NotificationService.cancel(t.id!);
    await DatabaseService.instance.deleteTask(t.id!);
    _load();
  }

  // নতুন task যোগ বা পুরনোটা edit করার পেজ খোলা
  Future<void> _openForm([Task? task]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
    );
    if (saved == true) _load();
  }

  Future<void> _logout() async {
    await NotificationService.cancelAll();
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _tab == 1
          ? AppBar(
        title: const Text('All Tasks'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout_rounded)),
        ],
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_tab == 0
          ? DashboardTab(
        tasks: _tasks,
        onToggle: _toggle,
        onEdit: _openForm,
        onDelete: _delete,
        onLogout: _logout,
      )
          : AllTasksTab(
        tasks: _tasks,
        onToggle: _toggle,
        onEdit: _openForm,
        onDelete: _delete,
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'All Tasks',
          ),
        ],
      ),
    );
  }
}