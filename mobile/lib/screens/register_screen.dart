import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService auth;
  const RegisterScreen({super.key, required this.auth});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.auth.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/app');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_humanizeRegisterError(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _humanizeRegisterError(Object e) {
    try {
      // Decode common 422 shape from Laravel: { message, errors: { field: [..] } }
      if (e is Exception && e.toString().contains('DioException')) {
        // Best effort parse
        final str = e.toString();
        if (str.contains('422')) {
          if (str.contains('email') && str.contains('has already been taken')) {
            return 'This email is already registered. Try logging in or use a different email.';
          }
          if (str.contains('password') && str.contains('confirmation')) {
            return 'Passwords do not match. Please confirm your password.';
          }
          if (str.contains('The email field must be a valid email address')) {
            return 'Please enter a valid email address.';
          }
          return 'Please check your inputs and try again.';
        }
      }
    } catch (_) {}
    return 'Register failed. Please try again.';
  }

  void _insertAtCursor(TextEditingController c, String text) {
    final sel = c.selection;
    if (!sel.isValid) {
      c.text = c.text + text;
      c.selection = TextSelection.fromPosition(
        TextPosition(offset: c.text.length),
      );
      return;
    }
    final start = sel.start;
    final end = sel.end;
    final newText = c.text.replaceRange(start, end, text);
    c.text = newText;
    final caret = start + text.length;
    c.selection = TextSelection.collapsed(offset: caret);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    suffixIcon: IconButton(
                      tooltip: 'Insert @',
                      icon: const Icon(Icons.alternate_email),
                      onPressed: _loading
                          ? null
                          : () => _insertAtCursor(_emailCtrl, '@'),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      (v != null && v.length >= 6) ? null : 'Min 6 chars',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                  ),
                  obscureText: true,
                  validator: (v) =>
                      v == _passCtrl.text ? null : 'Passwords do not match',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _onRegister,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
