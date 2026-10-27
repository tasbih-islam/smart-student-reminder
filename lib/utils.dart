import 'package:flutter/material.dart';
import 'theme.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// যেমন: Mon, 26 Oct 2026
String formatDate(DateTime d) =>
    '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

// যেমন: 9:30 AM
String formatTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ap';
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// task type অনুযায়ী রং ও আইকন
Color typeColor(String type) {
  switch (type) {
    case 'Exam':
      return AppColors.exam;
    case 'Class':
      return AppColors.classColor;
    default:
      return AppColors.assignment;
  }
}

IconData typeIcon(String type) {
  switch (type) {
    case 'Exam':
      return Icons.quiz_rounded;
    case 'Class':
      return Icons.school_rounded;
    default:
      return Icons.assignment_rounded;
  }
}