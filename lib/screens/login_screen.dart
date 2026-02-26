import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;
  String _emailError = '';
  String _passwordError = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return false;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      setState(() => _emailError = 'Please enter a valid email');
      return false;
    }
    setState(() => _emailError = '');
    return true;
  }

  bool _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return false;
    }
    if (value.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return false;
    }
    setState(() => _passwordError = '');
    return true;
  }

  Future<void> _handleLogin() async {
    final isEmailValid = _validateEmail(_emailController.text);
    final isPasswordValid = _validatePassword(_passwordController.text);

    if (isEmailValid && isPasswordValid) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    const Text(
                      'Task Manager',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Manage your tasks efficiently',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            placeholder: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                            onChanged: (value) {
                              if (_emailError.isNotEmpty) _validateEmail(value);
                            },
                            onFocusLost: () {
                              if (_emailController.text.isNotEmpty) {
                                _validateEmail(_emailController.text);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _passwordController,
                            placeholder: 'Password',
                            obscureText: !_showPassword,
                            errorText: _passwordError,
                            onChanged: (value) {
                              if (_passwordError.isNotEmpty) {
                                _validatePassword(value);
                              }
                            },
                            onFocusLost: () {
                              if (_passwordController.text.isNotEmpty) {
                                _validatePassword(_passwordController.text);
                              }
                            },
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  setState(() => _showPassword = !_showPassword),
                              child: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF6B7280),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                disabledBackgroundColor: const Color(0xFF93C5FD),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor:
                                const Color(0xFF2563EB).withOpacity(0.4),
                              ),
                              child: _isLoading
                                  ? const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Logging in...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                                  : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Secure login powered by Task Manager',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required String errorText,
    required ValueChanged<String> onChanged,
    required VoidCallback onFocusLost,
    Widget? suffixIcon,
  }) {
    final hasError = errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) onFocusLost();
          },
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              suffixIcon: suffixIcon != null
                  ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? const Color(0xFFEF4444) : Colors.transparent,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF3B82F6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ],
    );
  }
}