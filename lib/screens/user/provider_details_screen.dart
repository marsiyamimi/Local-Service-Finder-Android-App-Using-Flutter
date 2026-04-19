import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/provider_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

class ProviderDetailsScreen extends StatefulWidget {
  const ProviderDetailsScreen({super.key});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)!.settings.arguments as ProviderModel;
    final theme = Theme.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // Hero app bar
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              backgroundColor: theme.colorScheme.primary,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Hero(
                        tag: 'provider_avatar_${provider.id}',
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: provider.photoUrl != null
                              ? NetworkImage(provider.photoUrl!)
                              : null,
                          child: provider.photoUrl == null
                              ? Text(
                                  provider.name.isNotEmpty
                                      ? provider.name[0].toUpperCase()
                                      : 'P',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        provider.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          provider.serviceType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.star_rounded,
                          label: '${provider.rating.toStringAsFixed(1)} Rating',
                          color: AppColors.pending,
                        ),
                        const SizedBox(width: 10),
                        _InfoChip(
                          icon: Icons.reviews_rounded,
                          label: '${provider.reviewCount} Reviews',
                          color: AppColors.accepted,
                        ),
                        const SizedBox(width: 10),
                        _InfoChip(
                          icon: Icons.attach_money_rounded,
                          label: provider.priceFormatted,
                          color: AppColors.completed,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Availability
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: provider.isAvailable
                                ? AppColors.completed
                                : AppColors.rejected,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isAvailable
                              ? 'Available Now'
                              : 'Currently Unavailable',
                          style: TextStyle(
                            color: provider.isAvailable
                                ? AppColors.completed
                                : AppColors.rejected,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text('About', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      provider.description.isNotEmpty
                          ? provider.description
                          : 'Professional ${provider.serviceType} with years of experience providing quality service.',
                      style: theme.textTheme.bodyLarge,
                    ),

                    // Tags
                    if (provider.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: provider.tags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  padding: EdgeInsets.zero,
                                  side: BorderSide.none,
                                ))
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Rating display
                    Text('Rating', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: provider.rating,
                          itemBuilder: (ctx, _) => const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${provider.rating.toStringAsFixed(1)} / 5.0',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Location
                    if (provider.address != null) ...[
                      Text('Location', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 16,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              provider.address!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Map
                    Text('Location Map', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        child: (provider.lat != 0 || provider.lng != 0)
                            ? GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(provider.lat, provider.lng),
                                  zoom: 14,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('provider'),
                                    position:
                                        LatLng(provider.lat, provider.lng),
                                    infoWindow:
                                        InfoWindow(title: provider.name),
                                  ),
                                },
                                onMapCreated: (_) {},
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                              )
                            : _MapPlaceholder(
                                address: provider.address,
                                name: provider.name,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Book button
                    GradientButton(
                      text: 'Book Now',
                      icon: Icons.calendar_month_rounded,
                      onPressed: provider.isAvailable
                          ? () => Navigator.pushNamed(
                                context,
                                AppRoutes.bookService,
                                arguments: provider,
                              )
                          : null,
                      colors: provider.isAvailable
                          ? const [Color(0xFF2563EB), Color(0xFF7C3AED)]
                          : [Colors.grey.shade400, Colors.grey.shade500],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final String? address;
  final String name;

  const _MapPlaceholder({this.address, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 40,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              address?.isNotEmpty == true
                  ? address!
                  : 'Location will be confirmed after booking',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Provider location will appear after they set it up',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
