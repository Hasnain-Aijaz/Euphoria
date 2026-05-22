import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.netflixRed,
      ),
    );
  }

  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    String? error;
    if (_isLogin) {
      error = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      error = await ApiService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (error == null) {
        // After successful register, auto-login or switch to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please sign in.')),
        );
        setState(() {
          _isLogin = true;
          _isLoading = false;
        });
        return;
      }
    }

    if (error != null) {
      setState(() => _isLoading = false);
      _showError(error);
      return;
    }

    // Success - Token is saved inside ApiService.login
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          // Background Glows
          _buildGlow(-100, -100, AppTheme.netflixRed.withOpacity(0.15), 4),
          _buildGlow(null, -100, AppTheme.darkRed.withOpacity(0.15), 5, bottom: -50),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glowing Logo
                        _buildLogo(),

                        const SizedBox(height: 32),

                        // Dynamic Title
                        Text(
                          _isLogin ? 'Welcome Back' : 'Create Account',
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate(key: ValueKey('title_$_isLogin')).fadeIn(duration: 400.ms).slideY(begin: 0.2),

                        const SizedBox(height: 8),
                        Text(
                          _isLogin ? 'Sign in to continue listening' : 'Join the euphoria of music',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 15,
                          ),
                        ).animate(key: ValueKey('subtitle_$_isLogin')).fadeIn(duration: 400.ms),

                        const SizedBox(height: 40),

                        // Glassmorphic Form Container
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Username Field (Only for Sign Up)
                                  if (!_isLogin) ...[
                                    _buildTextField(
                                      controller: _usernameController,
                                      icon: Icons.person_outline,
                                      hint: 'Username',
                                      validator: (val) => (val == null || val.length < 3) 
                                          ? 'Username too short' : null,
                                    ).animate().fadeIn().slideY(begin: -0.2),
                                    const SizedBox(height: 20),
                                  ],

                                  // Email Field
                                  _buildTextField(
                                    controller: _emailController,
                                    icon: Icons.email_outlined,
                                    hint: 'Email',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) => (val == null || !val.contains('@')) 
                                        ? 'Enter a valid email' : null,
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  _buildTextField(
                                    controller: _passwordController,
                                    icon: Icons.lock_outline,
                                    hint: 'Password',
                                    isPassword: true,
                                    validator: (val) => (val == null || val.length < 8) 
                                        ? 'Password must be 8+ chars' : null,
                                  ),
                                  const SizedBox(height: 32),

                                  // Auth Button
                                  _buildSubmitButton(),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                        const SizedBox(height: 24),

                        // Toggle Mode Button
                        TextButton(
                          onPressed: _isLoading ? null : _toggleAuthMode,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                              children: [
                                TextSpan(text: _isLogin ? "Don't have an account? " : "Already have an account? "),
                                TextSpan(
                                  text: _isLogin ? 'Sign Up' : 'Sign In',
                                  style: const TextStyle(
                                    color: AppTheme.netflixRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms),

                        if (_isLogin)
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppTheme.textDim, fontSize: 13),
                            ),
                          ).animate().fadeIn(delay: 500.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(double? top, double? right, Color color, int duration, {double? bottom, double? left}) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: duration.seconds),
    );
  }

  Widget _buildLogo() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.netflixRed.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/euphoria_logo1.png',
          height: 90,
          width: 90,
          fit: BoxFit.cover,
        ),
      ),
    ).animate().scale(duration: 800.ms, curve: Curves.elasticOut);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.netflixRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: AppTheme.netflixRed.withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(_isLogin ? 'Sign In' : 'Create Account', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppTheme.textWhite),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Icon(icon, color: AppTheme.textMuted),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textMuted),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
