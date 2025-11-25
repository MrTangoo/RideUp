import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await ref.read(authControllerProvider.notifier).resetPassword(
          email: _emailController.text.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        setState(() => _emailSent = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView(theme) : _buildFormView(theme),
        ),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Icon(
            Icons.lock_reset,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Mot de passe oublié ?',
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez votre email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Email Field
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 32),
          
          // Reset Button
          CustomButton(
            text: 'Envoyer le lien',
            onPressed: _isLoading ? null : _handleResetPassword,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        
        // Success Icon
        Icon(
          Icons.check_circle_outline,
          size: 100,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        
        // Title
        Text(
          'Email envoyé !',
          style: theme.textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Message
        Text(
          'Nous avons envoyé un lien de réinitialisation à ${_emailController.text.trim()}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Vérifiez votre boîte de réception et suivez les instructions.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        
        // Back to Login Button
        CustomButton(
          text: 'Retour à la connexion',
          onPressed: () => context.pop(),
        ),
        const SizedBox(height: 16),
        
        // Resend Link
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text('Renvoyer le lien'),
        ),
      ],
    );
  }
}
