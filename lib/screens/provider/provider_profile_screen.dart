import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/provider_model.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import 'location_picker_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;
  final bool showAsTab;

  const ProviderProfileScreen({
    super.key,
    required this.providerId,
    this.showAsTab = false,
  });

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _service = FirestoreService();
  ProviderModel? _provider;
  bool _isEditing = false;
  bool _isLoading = false;

  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _selectedService;

  // Location state
  double _pickedLat = 0;
  double _pickedLng = 0;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final p = await _service.getProviderByUserId(widget.providerId);
    if (mounted) {
      setState(() {
        _provider = p;
        if (p != null) {
          _descCtrl.text = p.description;
          _priceCtrl.text = p.price.toString();
          _addressCtrl.text = p.address ?? '';
          _selectedService = p.serviceType.isNotEmpty ? p.serviceType : null;
          _pickedLat = p.lat;
          _pickedLng = p.lng;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_provider == null) return;
    setState(() => _isLoading = true);
    try {
      await _service.updateProviderProfile(_provider!.id, {
        'description': _descCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'address': _addressCtrl.text.trim(),
        'service_type': _selectedService ?? _provider!.serviceType,
        'isAvailable': true,
        'location': {
          'lat': _pickedLat,
          'lng': _pickedLng,
        },
      });
      await _loadProvider();
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: AppColors.completed,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLat: _pickedLat,
          initialLng: _pickedLng,
          initialAddress: _addressCtrl.text.isNotEmpty ? _addressCtrl.text : null,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _pickedLat = result['lat'] as double;
        _pickedLng = result['lng'] as double;
        _addressCtrl.text = result['address'] as String;
      });
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final themeCtrl = context.watch<ThemeController>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: widget.showAsTab
          ? null
          : AppBar(
              title: const Text('My Profile'),
              actions: [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
              ],
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (widget.showAsTab) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profile', style: theme.textTheme.headlineMedium),
                    if (!_isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Avatar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.cardTheme.color,
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(user?.name ?? '', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PROVIDER',
                  style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Provider stats
              if (_provider != null) ...[
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.star_rounded,
                      value: _provider!.rating.toStringAsFixed(1),
                      label: 'Rating',
                      color: AppColors.pending,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.attach_money_rounded,
                      value: _provider!.priceFormatted,
                      label: 'Rate',
                      color: AppColors.completed,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.reviews_rounded,
                      value: '${_provider!.reviewCount}',
                      label: 'Reviews',
                      color: AppColors.accepted,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Edit form or view
              if (_isEditing && _provider != null) ...[
                AnimatedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit Profile', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),

                      // Service type
                      Text('Service Type', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedService,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        hint: const Text('Select service'),
                        items: serviceCategories
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedService = v),
                      ),

                      const SizedBox(height: 14),
                      CustomTextField(
                        hint: 'Hourly rate (e.g. 50)',
                        prefixIcon: Icons.attach_money_rounded,
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hint: 'Address / Location',
                        prefixIcon: Icons.location_on_outlined,
                        controller: _addressCtrl,
                      ),
                      const SizedBox(height: 10),

                      // Location picker button
                      GestureDetector(
                        onTap: _pickLocation,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.map_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pin on Map',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _pickedLat != 0
                                          ? 'Lat: ${_pickedLat.toStringAsFixed(4)}, Lng: ${_pickedLng.toStringAsFixed(4)}'
                                          : 'Tap to pick your location on map',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hint: 'Bio / Description',
                        prefixIcon: Icons.description_outlined,
                        controller: _descCtrl,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _isEditing = false),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              text: 'Save',
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _saveProfile,
                              colors: const [
                                Color(0xFF7C3AED),
                                Color(0xFF2563EB),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (_provider != null) ...[
                AnimatedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service Info', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.home_repair_service_rounded,
                        label: 'Service',
                        value: _provider!.serviceType.isNotEmpty
                            ? _provider!.serviceType
                            : 'Not set',
                        theme: theme,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.attach_money_rounded,
                        label: 'Hourly Rate',
                        value: _provider!.priceFormatted,
                        theme: theme,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: _provider!.address?.isNotEmpty == true
                            ? _provider!.address!
                            : 'Not set',
                        theme: theme,
                      ),
                      if (_provider!.description.isNotEmpty) ...[
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.description_outlined,
                          label: 'Bio',
                          value: _provider!.description,
                          theme: theme,
                        ),
                      ],
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.my_location_rounded,
                        label: 'GPS',
                        value: _provider!.lat != 0
                            ? '${_provider!.lat.toStringAsFixed(4)}, ${_provider!.lng.toStringAsFixed(4)}'
                            : 'Not set',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Theme toggle
              AnimatedCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dark Mode', style: theme.textTheme.bodyLarge),
                        Switch.adaptive(
                          value: themeCtrl.isDark,
                          onChanged: (_) => themeCtrl.toggleTheme(),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Accent Color', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: themeCtrl.colorOptions.map((opt) {
                        final isSelected =
                            themeCtrl.primaryColor == opt['color'] as Color;
                        return GestureDetector(
                          onTap: () =>
                              themeCtrl.setPrimaryColor(opt['color'] as Color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 34,
                            height: 34,
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
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 15)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Logout
              AnimatedCard(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content:
                          const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sign Out',
                              style: TextStyle(color: AppColors.rejected)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await context.read<AuthController>().signOut();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.rejected.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: AppColors.rejected, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Sign Out',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.rejected,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
