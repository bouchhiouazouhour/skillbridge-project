import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService auth;
  const LoginScreen({super.key, required this.auth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.auth.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/app');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'SkillBridge',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enhance your CV efficiently',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                TextFormField(
                  controller: _emailCtrl,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Email is required' : null,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _onLogin,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log in'),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pushNamed('/register'),
                    child: const Text("Create an account"),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(context).pushReplacementNamed('/app');
                          },
                    child: const Text('Continue as guest'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            _emailCtrl.text = 'test@example.com';
                            _passCtrl.text = 'password';
                            _onLogin();
                          },
                    child: const Text('Use test account'),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
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
}
