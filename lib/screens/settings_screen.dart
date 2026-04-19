import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_controller.dart';
import '../widgets/animated_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCtrl = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            AnimatedCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              themeCtrl.isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Dark Mode', style: theme.textTheme.bodyLarge),
                        ],
                      ),
                      Switch.adaptive(
                        value: themeCtrl.isDark,
                        onChanged: (_) => themeCtrl.toggleTheme(),
                        activeThumbColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.palette_rounded,
                            color: theme.colorScheme.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text('Accent Color', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: themeCtrl.colorOptions.map((opt) {
                      final isSelected =
                          themeCtrl.primaryColor == opt['color'] as Color;
                      final colorName = opt['name'] as String;
                      return GestureDetector(
                        onTap: () =>
                            themeCtrl.setPrimaryColor(opt['color'] as Color),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: opt['color'] as Color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: theme.scaffoldBackgroundColor,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: (opt['color'] as Color)
                                              .withOpacity(0.5),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              colorName,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('About', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    label: 'App Version',
                    trailing: '1.0.0',
                  ),
                  const Divider(height: 20),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    trailing: null,
                    onTap: () {},
                  ),
                  const Divider(height: 20),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    trailing: null,
                    onTap: () {},
                  ),
                  const Divider(height: 20),
                  _SettingsTile(
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    trailing: null,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          if (trailing != null)
            Text(trailing!, style: theme.textTheme.bodyMedium)
          else if (onTap != null)
            Icon(Icons.chevron_right_rounded,
                color: theme.textTheme.bodyMedium?.color),
        ],
      ),
    );
  }
}
