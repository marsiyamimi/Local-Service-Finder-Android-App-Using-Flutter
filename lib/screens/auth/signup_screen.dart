import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user';

  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnims = List.generate(
      6,
      (i) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(i * 0.08, 0.5 + i * 0.08, curve: Curves.easeOut),
      )),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = await auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(
        context,
        _selectedRole == 'provider'
            ? AppRoutes.providerDashboard
            : AppRoutes.userHome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: -60,
                      right: -60,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Join thousands of users & providers',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Role Selection
                      SlideTransition(
                        position: _slideAnims[0],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('I want to...',
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _RoleTile(
                                  label: 'Find Services',
                                  subtitle: 'Book local professionals',
                                  icon: Icons.search_rounded,
                                  value: 'user',
                                  selectedValue: _selectedRole,
                                  onSelect: (v) =>
                                      setState(() => _selectedRole = v),
                                ),
                                const SizedBox(width: 12),
                                _RoleTile(
                                  label: 'Offer Services',
                                  subtitle: 'Work as a professional',
                                  icon: Icons.handyman_rounded,
                                  value: 'provider',
                                  selectedValue: _selectedRole,
                                  onSelect: (v) =>
                                      setState(() => _selectedRole = v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Name
                      SlideTransition(
                        position: _slideAnims[1],
                        child: CustomTextField(
                          hint: 'Full name',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: _nameController,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Enter name';
                            if (val.length < 2) return 'Name too short';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Email
                      SlideTransition(
                        position: _slideAnims[2],
                        child: CustomTextField(
                          hint: 'Email address',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Enter email';
                            if (!val.contains('@')) return 'Enter valid email';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password
                      SlideTransition(
                        position: _slideAnims[3],
                        child: CustomTextField(
                          hint: 'Password (min 6 chars)',
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _passwordController,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Enter password';
                            if (val.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Error
                      Consumer<AuthController>(
                        builder: (_, auth, __) {
                          if (auth.errorMessage != null) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8, top: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.rejected.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.rejected.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: AppColors.rejected, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(auth.errorMessage!,
                                        style: const TextStyle(
                                            color: AppColors.rejected,
                                            fontSize: 13)),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox(height: 8);
                        },
                      ),

                      // Sign Up Button
                      SlideTransition(
                        position: _slideAnims[4],
                        child: Consumer<AuthController>(
                          builder: (_, auth, __) => GradientButton(
                            text: 'Create Account',
                            isLoading: auth.isLoading,
                            onPressed: auth.isLoading ? null : _signup,
                            colors: const [
                              Color(0xFF7C3AED),
                              Color(0xFF2563EB),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login link
                      SlideTransition(
                        position: _slideAnims[5],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: theme.textTheme.bodyMedium),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final String value;
  final String selectedValue;
  final void Function(String) onSelect;

  const _RoleTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == selectedValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(theme.brightness == Brightness.dark ? 0.15 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
