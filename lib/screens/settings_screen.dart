import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _reminderTime = '06:30';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('settings');
    final userJson = prefs.getString('user');
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson);
      setState(() {
        _darkMode = settings['darkMode'] ?? false;
        _notificationsEnabled = settings['notificationsEnabled'] ?? true;
        _reminderTime = settings['reminderTime'] ?? '06:30';
      });
    }
    if (userJson != null) {
      final user = jsonDecode(userJson);
      _nameController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();

    // Save user data
    await prefs.setString('user', jsonEncode({
      'name': _nameController.text,
      'email': _emailController.text,
    }));

    // Save settings
    await prefs.setString('settings', jsonEncode({
      'darkMode': _darkMode,
      'notificationsEnabled': _notificationsEnabled,
      'reminderTime': _reminderTime,
    }));

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Color(0xFF1D9E75),
        ),
      );
    }
  }

  Future<void> _pickReminderTime() async {
    final parts = _reminderTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF7F77DD)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7F77DD),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF7F77DD), size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF7F77DD)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7F77DD), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF111827))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7F77DD),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF7F77DD)))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      color: const Color(0xFF7F77DD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 12),
                          const Text('Edit profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Update your personal information', style: TextStyle(color: Color(0xFFCECBF6), fontSize: 13)),
                          const SizedBox(height: 16),
                          // Avatar
                          Center(
                            child: Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Color(0xFFAFA9EC),
                                  child: Text('JD', style: TextStyle(color: Color(0xFF26215C), fontWeight: FontWeight.w600, fontSize: 24)),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF7F77DD), width: 1.5),
                                    ),
                                    child: const Icon(Icons.edit, size: 13, color: Color(0xFF7F77DD)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile section
                          _buildSectionTitle('Personal information'),
                          _buildTextField(controller: _nameController, label: 'Full name', icon: Icons.person_outline, hint: 'John Doe'),
                          _buildTextField(controller: _emailController, label: 'Email address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, hint: 'john@email.com'),

                          // Preferences section
                          _buildSectionTitle('Preferences'),
                          _buildToggleItem(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark mode',
                            subtitle: _darkMode ? 'Currently on' : 'Currently off',
                            value: _darkMode,
                            onChanged: (val) => setState(() => _darkMode = val),
                          ),
                          const SizedBox(height: 10),
                          _buildToggleItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                            value: _notificationsEnabled,
                            onChanged: (val) => setState(() => _notificationsEnabled = val),
                          ),
                          const SizedBox(height: 10),

                          // Reminder time picker
                          GestureDetector(
                            onTap: _pickReminderTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFEEEEEE)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.alarm_outlined, color: Color(0xFF7F77DD), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Daily reminder', style: TextStyle(fontSize: 13, color: Color(0xFF111827))),
                                        Text(_reminderTime, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                                ],
                              ),
                            ),
                          ),

                          // Theme selector
                          _buildSectionTitle('Theme'),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _darkMode = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_darkMode ? const Color(0xFF7F77DD) : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: !_darkMode ? const Color(0xFF7F77DD) : const Color(0xFFEEEEEE)),
                                    ),
                                    child: Center(
                                      child: Text('Light', style: TextStyle(fontSize: 13, color: !_darkMode ? Colors.white : Colors.grey, fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _darkMode = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _darkMode ? const Color(0xFF7F77DD) : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: _darkMode ? const Color(0xFF7F77DD) : const Color(0xFFEEEEEE)),
                                    ),
                                    child: Center(
                                      child: Text('Dark', style: TextStyle(fontSize: 13, color: _darkMode ? Colors.white : Colors.grey, fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7F77DD),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Save changes', style: TextStyle(fontSize: 15, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
