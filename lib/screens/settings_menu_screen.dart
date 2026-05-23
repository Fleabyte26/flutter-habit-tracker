import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsMenuScreen extends StatefulWidget {
  const SettingsMenuScreen({super.key});

  @override
  State<SettingsMenuScreen> createState() => _SettingsMenuScreenState();
}

class _SettingsMenuScreenState extends State<SettingsMenuScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _reminderTime = '06:30';
  String _userName = 'John Doe';
  String _userEmail = 'john@email.com';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
      setState(() {
        _userName = user['name'] ?? 'John Doe';
        _userEmail = user['email'] ?? 'john@email.com';
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode({
      'darkMode': _darkMode,
      'notificationsEnabled': _notificationsEnabled,
      'reminderTime': _reminderTime,
    }));
  }

  void _toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
    _saveSettings();
  }

  void _toggleNotifications(bool value) {
    setState(() => _notificationsEnabled = value);
    _saveSettings();
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7F77DD))),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? const Color(0xFF7F77DD), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, color: titleColor ?? const Color(0xFF111827))),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 46, color: Color(0xFFEEEEEE));
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
                          const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Manage your preferences', style: TextStyle(color: Color(0xFFCECBF6), fontSize: 13)),
                          const SizedBox(height: 16),
                          // User summary card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(0xFFAFA9EC),
                                  child: Text('JD', style: TextStyle(color: Color(0xFF26215C), fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                    Text(_userEmail, style: const TextStyle(color: Color(0xFFCECBF6), fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Account section
                    _buildSectionTitle('Account'),
                    _buildMenuGroup([
                      _buildMenuItem(icon: Icons.person_outline, title: 'Edit profile', subtitle: 'Update your name and email', onTap: () => Navigator.pushNamed(context, '/edit-profile')),
                      _buildDivider(),
                      _buildMenuItem(icon: Icons.lock_outline, title: 'Change password', subtitle: 'Update your password', onTap: () => Navigator.pushNamed(context, '/change-password')),
                    ]),

                    // Preferences section
                    _buildSectionTitle('Preferences'),
                    _buildMenuGroup([
                      _buildMenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark mode',
                        subtitle: _darkMode ? 'On' : 'Off',
                        trailing: Switch(value: _darkMode, onChanged: _toggleDarkMode, activeColor: const Color(0xFF7F77DD)),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                        trailing: Switch(value: _notificationsEnabled, onChanged: _toggleNotifications, activeColor: const Color(0xFF7F77DD)),
                      ),
                      _buildDivider(),
                      _buildMenuItem(icon: Icons.language_outlined, title: 'Language', subtitle: 'English', onTap: () {}),
                      _buildDivider(),
                      _buildMenuItem(icon: Icons.notifications_active_outlined, title: 'Reminder time', subtitle: _reminderTime, onTap: () => Navigator.pushNamed(context, '/notifications')),
                    ]),

                    // Support section
                    _buildSectionTitle('Support'),
                    _buildMenuGroup([
                      _buildMenuItem(icon: Icons.help_outline, title: 'Help center', onTap: () {}),
                      _buildDivider(),
                      _buildMenuItem(icon: Icons.info_outline, title: 'About', subtitle: 'HabitFlow v1.0.0', onTap: () {}),
                      _buildDivider(),
                      _buildMenuItem(icon: Icons.privacy_tip_outlined, title: 'Privacy policy', onTap: () {}),
                    ]),

                    // Sign out
                    _buildSectionTitle('Account actions'),
                    _buildMenuGroup([
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Sign out',
                        titleColor: Colors.red,
                        trailing: const SizedBox.shrink(),
                        onTap: _handleLogout,
                      ),
                    ]),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
