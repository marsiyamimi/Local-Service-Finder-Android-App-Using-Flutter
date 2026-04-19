import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/provider_model.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../widgets/provider_card.dart';

class ProviderListScreen extends StatefulWidget {
  final String? initialCategory;
  final bool showAsTab;

  const ProviderListScreen({
    super.key,
    this.initialCategory,
    this.showAsTab = false,
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final FirestoreService _service = FirestoreService();
  String? _selectedCategory;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _selectedCategory == null) {
      _selectedCategory = arg;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.showAsTab
          ? null
          : AppBar(
              title: Text(
                _selectedCategory ?? 'All Providers',
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: _showFilter,
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.showAsTab)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Explore', style: theme.textTheme.headlineMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: _showFilter,
                    ),
                  ],
                ),
              ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search providers...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Category chips
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...serviceCategories.map(
                    (c) => _CategoryChip(
                      label: c,
                      isSelected: _selectedCategory == c,
                      onTap: () => setState(() => _selectedCategory =
                          _selectedCategory == c ? null : c),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Providers list
            Expanded(
              child: StreamBuilder<List<ProviderModel>>(
                stream: _service.getProviders(serviceType: _selectedCategory),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text('Error: ${snap.error}',
                          style: theme.textTheme.bodyMedium),
                    );
                  }

                  var providers = snap.data ?? [];

                  // Filter by search
                  if (_searchQuery.isNotEmpty) {
                    providers = providers
                        .where((p) =>
                            p.name.toLowerCase().contains(
                                _searchQuery.toLowerCase()) ||
                            p.serviceType.toLowerCase().contains(
                                _searchQuery.toLowerCase()) ||
                            p.description.toLowerCase().contains(
                                _searchQuery.toLowerCase()))
                        .toList();
                  }

                  if (providers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No providers found',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try a different category or search',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: providers.length,
                      itemBuilder: (ctx, i) {
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            verticalOffset: 40,
                            child: FadeInAnimation(
                              child: ProviderCard(
                                provider: providers[i],
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.providerDetails,
                                  arguments: providers[i],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Filter by Category',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    Navigator.pop(ctx);
                  },
                ),
                ...serviceCategories.map(
                  (c) => _CategoryChip(
                    label: c,
                    isSelected: _selectedCategory == c,
                    onTap: () {
                      setState(() => _selectedCategory = c);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
