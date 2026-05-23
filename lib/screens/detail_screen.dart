import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Habit habit;
  List<String> completedDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        habit = ModalRoute.of(context)!.settings.arguments as Habit;
      });
      _loadCompletedDates();
    });
  }

  Future<void> _loadCompletedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final datesJson = prefs.getString('dates_${habit.id}');
    if (datesJson != null) {
      setState(() {
        completedDates = List<String>.from(jsonDecode(datesJson));
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _markAsComplete() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (!completedDates.contains(today)) {
      setState(() {
        completedDates.add(today);
        habit.isCompletedToday = true;
        habit.streak++;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dates_${habit.id}', jsonEncode(completedDates));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit marked as complete!'),
            backgroundColor: Color(0xFF1D9E75),
          ),
        );
      }
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString('habits');
      if (habitsJson != null) {
        final List decoded = jsonDecode(habitsJson);
        final habits = decoded.map((e) => Habit.fromJson(e)).toList();
        habits.removeWhere((h) => h.id == habit.id);
        await prefs.setString('habits', jsonEncode(habits.map((e) => e.toJson()).toList()));
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF7F77DD))));
    }

    final completionRate = completedDates.length / 30;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                color: const Color(0xFF7F77DD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back_ios, color: Color(0xFFCECBF6), size: 16),
                              Text('Back', style: TextStyle(color: Color(0xFFCECBF6), fontSize: 13)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _deleteHabit,
                          child: const Icon(Icons.delete_outline, color: Color(0xFFCECBF6), size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(habit.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${habit.frequency} · ${habit.category}', style: const TextStyle(color: Color(0xFFCECBF6), fontSize: 13)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    Row(
                      children: [
                        _statCard('${habit.streak}', 'Day streak'),
                        const SizedBox(width: 10),
                        _statCard('${completedDates.length}', 'Total done'),
                        const SizedBox(width: 10),
                        _statCard('${(completionRate * 100).toInt()}%', 'Completion'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Calendar
                    const Text('This month', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(30, (index) {
                        final day = index + 1;
                        final date = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                        final isDone = completedDates.contains(date);
                        return Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDone ? const Color(0xFF1D9E75) : const Color(0xFFEEEDFE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(fontSize: 9, color: isDone ? Colors.white : const Color(0xFF7F77DD), fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Reminder
                    const Text('Reminder', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('6:30 AM daily', style: TextStyle(fontSize: 13, color: Color(0xFF3C3489), fontWeight: FontWeight.w500)),
                          Icon(Icons.notifications_outlined, color: Color(0xFF7F77DD), size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mark as done button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: habit.isCompletedToday ? null : _markAsComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: habit.isCompletedToday ? Colors.grey.shade300 : const Color(0xFF1D9E75),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          habit.isCompletedToday ? 'Completed today!' : 'Mark as done today',
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEDFE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF534AB7))),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF7F77DD))),
          ],
        ),
      ),
    );
  }
}
