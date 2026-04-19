import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../controllers/auth_controller.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';

class MyBookingsScreen extends StatefulWidget {
  final bool showAsTab;
  const MyBookingsScreen({super.key, this.showAsTab = false});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = context.read<AuthController>().currentUser?.id ?? '';

    return Scaffold(
      appBar: widget.showAsTab
          ? null
          : AppBar(title: const Text('My Bookings')),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.showAsTab)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('My Bookings', style: theme.textTheme.headlineMedium),
                ),
              ),

            // Tab bar
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Active'),
                  Tab(text: 'Done'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<List<BookingModel>>(
                stream: _service.getUserBookings(userId),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }

                  final all = snap.data ?? [];

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _BookingList(bookings: all, service: _service),
                      _BookingList(
                        bookings: all
                            .where((b) => b.status == BookingStatus.pending)
                            .toList(),
                        service: _service,
                      ),
                      _BookingList(
                        bookings: all
                            .where((b) => b.status == BookingStatus.accepted)
                            .toList(),
                        service: _service,
                      ),
                      _BookingList(
                        bookings: all
                            .where((b) =>
                                b.status == BookingStatus.completed ||
                                b.status == BookingStatus.rejected)
                            .toList(),
                        service: _service,
                      ),
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

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final FirestoreService service;

  const _BookingList({required this.bookings, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text('No bookings yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Your bookings will appear here',
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.home_repair_service_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.providerName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  booking.serviceType,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: booking.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                          height: 1, color: theme.dividerTheme.color),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 13,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              booking.scheduledDate != null
                                  ? booking.scheduledDateFormatted
                                  : _formatDate(booking.timestamp),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (booking.price != null)
                            Text(
                              '\$${booking.price!.toStringAsFixed(0)}/hr',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                      if (booking.userNote != null &&
                          booking.userNote!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Cancel button for pending
                      if (booking.status == BookingStatus.pending) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _confirmCancel(context, booking),
                            icon: const Icon(Icons.cancel_outlined,
                                size: 16, color: AppColors.rejected),
                            label: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.rejected,
                                fontSize: 13,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
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

  void _confirmCancel(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await service.deleteBooking(booking.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled'),
                    backgroundColor: AppColors.rejected,
                  ),
                );
              }
            },
            child: const Text('Cancel Booking',
                style: TextStyle(color: AppColors.rejected)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
