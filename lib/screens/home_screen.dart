import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Habit {
  final String id;
  final String name;
  final String category;
  final String frequency;
  bool isCompletedToday;
  int streak;

  Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.frequency,
    this.isCompletedToday = false,
    this.streak = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'frequency': frequency,
        'isCompletedToday': isCompletedToday,
        'streak': streak,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        frequency: json['frequency'],
        isCompletedToday: json['isCompletedToday'],
        streak: json['streak'],
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('habits');
    if (habitsJson != null) {
      final List decoded = jsonDecode(habitsJson);
      setState(() {
        _habits = decoded.map((e) => Habit.fromJson(e)).toList();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = jsonEncode(_habits.map((e) => e.toJson()).toList());
    await prefs.setString('habits', habitsJson);
  }

  void _toggleHabit(int index) {
    setState(() {
      _habits[index].isCompletedToday = !_habits[index].isCompletedToday;
      if (_habits[index].isCompletedToday) {
        _habits[index].streak++;
      } else {
        if (_habits[index].streak > 0) _habits[index].streak--;
      }
    });
    _saveHabits();
  }

  void _addHabit() {
    Navigator.pushNamed(context, '/add-habit').then((_) => _loadHabits());
  }

  int get _completedCount => _habits.where((h) => h.isCompletedToday).length;

  double get _completionRate =>
      _habits.isEmpty ? 0 : _completedCount / _habits.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: const Color(0xFF7F77DD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Good morning!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                          Text('$_completedCount of ${_habits.length} habits done today', style: const TextStyle(color: Color(0xFFCECBF6), fontSize: 13)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFAFA9EC),
                          child: Text('JD', style: TextStyle(color: Color(0xFF26215C), fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _completionRate,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${(_completionRate * 100).toInt()}% complete', style: const TextStyle(color: Color(0xFFCECBF6), fontSize: 11)),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF7F77DD)))
                  : _habits.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.track_changes, size: 64, color: Color(0xFFCECBF6)),
                              SizedBox(height: 16),
                              Text('No habits yet!', style: TextStyle(fontSize: 18, color: Color(0xFF7F77DD), fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              Text('Tap + to add your first habit', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/habit-detail', arguments: habit),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: habit.isCompletedToday ? const Color(0xFFEEEDFE) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: habit.isCompletedToday ? const Color(0xFFAFA9EC) : const Color(0xFFEEEEEE)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(habit.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: habit.isCompletedToday ? const Color(0xFF3C3489) : const Color(0xFF111827))),
                                          const SizedBox(height: 2),
                                          Text('${habit.streak} day streak · ${habit.category}', style: TextStyle(fontSize: 11, color: habit.isCompletedToday ? const Color(0xFF7F77DD) : Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _toggleHabit(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: habit.isCompletedToday ? const Color(0xFF1D9E75) : Colors.transparent,
                                          border: Border.all(color: habit.isCompletedToday ? const Color(0xFF1D9E75) : Colors.grey.shade300, width: 2),
                                        ),
                                        child: habit.isCompletedToday ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Container(
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                  if (index == 1) Navigator.pushNamed(context, '/stats');
                  if (index == 2) Navigator.pushNamed(context, '/favorites');
                  if (index == 3) Navigator.pushNamed(context, '/profile');
                },
                selectedItemColor: const Color(0xFF7F77DD),
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.white,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
                  BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Favorites'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        backgroundColor: const Color(0xFF7F77DD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
