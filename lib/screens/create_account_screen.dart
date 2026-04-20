import 'package:flutter/material.dart';

import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CreateAccountScreen extends StatefulWidget {
  final AppState appState;

  const CreateAccountScreen({
    super.key,
    required this.appState,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _loading = false;
  bool _signInMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (_signInMode) {
        await widget.appState.signIn(email: email, password: password);
      } else {
        await widget.appState.signUp(
          email: email,
          password: password,
          displayName: name,
        );
      }

      await widget.appState.loadAllData();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.lists);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Panel(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HappyShopperLogo(),
            const SizedBox(height: 22),
            Text(
              _signInMode ? 'Sign In' : 'Create an Account',
              style: UI.title(),
            ),
            const SizedBox(height: 18),

            // Email / username always first.
            TextField(
              controller: _emailController,
              style: UI.inputText,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: UI.input('email'),
            ),
            const SizedBox(height: 10),

            // Password second.
            TextField(
              controller: _passwordController,
              style: UI.inputText,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: UI.input('password'),
            ),

            // Sign-up gets an optional display name after password.
            if (!_signInMode) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: UI.inputText,
                decoration: UI.input('display name (optional)'),
              ),
            ],

            const SizedBox(height: 18),
            PrimaryPillButton(
              label: _loading
                  ? 'please wait...'
                  : (_signInMode ? 'sign in' : 'continue'),
              onTap: _loading ? null : _submit,
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _signInMode = !_signInMode;
                      });
                    },
              child: Text(
                _signInMode
                    ? 'Need an account? Create one'
                    : 'Already have an account? Sign in',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
