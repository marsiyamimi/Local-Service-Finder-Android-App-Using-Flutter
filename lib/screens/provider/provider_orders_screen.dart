import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';

class ProviderOrdersScreen extends StatefulWidget {
  final String providerId;
  final bool showAsTab;

  const ProviderOrdersScreen({
    super.key,
    required this.providerId,
    this.showAsTab = false,
  });

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState extends State<ProviderOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.showAsTab ? null : AppBar(title: const Text('Orders')),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.showAsTab)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Orders', style: theme.textTheme.headlineMedium),
                ),
              ),

            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Active'),
                  Tab(text: 'History'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<List<BookingModel>>(
                stream: _service.getProviderBookings(widget.providerId),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? [];
                  final pending = all
                      .where((b) => b.status == BookingStatus.pending)
                      .toList();
                  final active = all
                      .where((b) => b.status == BookingStatus.accepted)
                      .toList();
                  final history = all
                      .where((b) =>
                          b.status == BookingStatus.completed ||
                          b.status == BookingStatus.rejected)
                      .toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _OrderList(
                        bookings: pending,
                        service: _service,
                        showActions: true,
                      ),
                      _OrderList(
                        bookings: active,
                        service: _service,
                        showComplete: true,
                      ),
                      _OrderList(bookings: history, service: _service),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<BookingModel> bookings;
  final FirestoreService service;
  final bool showActions;
  final bool showComplete;

  const _OrderList({
    required this.bookings,
    required this.service,
    this.showActions = false,
    this.showComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 60,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text('No orders here', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Orders will appear when customers book',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: bookings.length,
        itemBuilder: (ctx, i) {
          final booking = bookings[i];
          return AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 30,
              child: FadeInAnimation(
                child: AnimatedCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              (booking.userName?.isNotEmpty == true)
                                  ? booking.userName![0].toUpperCase()
                                  : 'C',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.userName ?? 'Customer',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontSize: 15),
                                ),
                                Text(
                                  booking.userEmail ?? '',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: booking.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: theme.dividerTheme.color),
                      const SizedBox(height: 10),

                      // Details
                      _DetailRow(
                        icon: Icons.home_repair_service_rounded,
                        label: booking.serviceType,
                        theme: theme,
                      ),
                      const SizedBox(height: 4),
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: booking.scheduledDate != null
                            ? booking.scheduledDateFormatted
                            : _formatDate(booking.timestamp),
                        theme: theme,
                      ),
                      if (booking.price != null) ...[
                        const SizedBox(height: 4),
                        _DetailRow(
                          icon: Icons.attach_money_rounded,
                          label: '\$${booking.price!.toStringAsFixed(0)}/hr',
                          theme: theme,
                          valueColor: theme.colorScheme.primary,
                        ),
                      ],

                      if (booking.userNote != null &&
                          booking.userNote!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.notes_rounded,
                                  size: 13,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  booking.userNote!,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Action buttons
                      if (showActions) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateStatus(
                                  context,
                                  booking,
                                  BookingStatus.rejected,
                                ),
                                icon: const Icon(Icons.close_rounded, size: 16),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.rejected,
                                  side: const BorderSide(
                                      color: AppColors.rejected),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(
                                  context,
                                  booking,
                                  BookingStatus.accepted,
                                ),
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accepted,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (showComplete) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _updateStatus(
                              context,
                              booking,
                              BookingStatus.completed,
                            ),
                            icon: const Icon(Icons.task_alt_rounded, size: 16),
                            label: const Text('Mark as Completed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.completed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    BookingModel booking,
    BookingStatus newStatus,
  ) async {
    await service.updateBookingStatus(booking.id, newStatus);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking ${newStatus.label.toLowerCase()}!'),
          backgroundColor: newStatus == BookingStatus.accepted
              ? AppColors.accepted
              : newStatus == BookingStatus.completed
                  ? AppColors.completed
                  : AppColors.rejected,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 13,
            color: valueColor ?? theme.textTheme.bodyMedium?.color),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: valueColor,
            fontWeight: valueColor != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}
