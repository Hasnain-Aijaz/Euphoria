import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await ApiService.getMe();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  void _handleLogout(BuildContext context) async {
    await ApiService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not implemented yet!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.netflixRed)),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: AppTheme.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load profile', style: TextStyle(color: Colors.white)),
              TextButton(onPressed: _loadUserProfile, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.textWhite,
            ),
            onPressed: () => _showNotImplemented(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.netflixRed,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.netflixRed.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: AppTheme.netflixRed, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _user!.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.username,
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _user!.email,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _user!.isAdmin ? AppTheme.netflixRed.withOpacity(0.1) : AppTheme.surfaceGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _user!.isAdmin ? AppTheme.netflixRed : AppTheme.borderGrey),
                    ),
                    child: Text(
                      _user!.role,
                      style: TextStyle(
                        color: _user!.isAdmin ? AppTheme.netflixRed : AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (_user!.isAdmin) ...[
                        _buildSectionCard(
                          title: 'Admin Controls',
                          children: [
                            ListTile(
                              leading: const Icon(Icons.admin_panel_settings, color: AppTheme.netflixRed),
                              title: const Text(
                                'Admin Dashboard',
                                style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Upload songs, manage artists & albums',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: AppTheme.netflixRed),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      _buildSectionCard(
                        title: 'Account Settings',
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            onTap: () => _showNotImplemented(context),
                          ),
                          _SettingsTile(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            onTap: () => _showNotImplemented(context),
                          ),
                          _SettingsTile(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            onTap: () => _showNotImplemented(context),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),

                      _buildSectionCard(
                        title: 'App Preferences',
                        children: [
                          _SettingsTile(
                            icon: Icons.language,
                            title: 'Language',
                            trailing: 'English',
                            onTap: () => _showNotImplemented(context),
                          ),
                          _SettingsTile(
                            icon: Icons.info_outline,
                            title: 'About Euphoria',
                            onTap: () => _showNotImplemented(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppTheme.netflixRed,
                            shadowColor: Colors.transparent,
                            side: const BorderSide(color: AppTheme.netflixRed, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Log Out',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceGrey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderGrey.withOpacity(0.5)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textLight, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.textWhite, fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
