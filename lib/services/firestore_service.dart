import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/provider_model.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Providers ────────────────────────────────────────────────────────

  Stream<List<ProviderModel>> getProviders({String? serviceType}) {
    Query<Map<String, dynamic>> query = _db.collection('providers');
    if (serviceType != null && serviceType.isNotEmpty) {
      query = query.where('service_type', isEqualTo: serviceType);
    }
    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => ProviderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<ProviderModel?> getProvider(String providerId) async {
    final doc = await _db.collection('providers').doc(providerId).get();
    if (doc.exists) {
      return ProviderModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<ProviderModel?> getProviderByUserId(String userId) async {
    // First try by document ID (fast path — provider doc ID = user UID)
    final doc = await _db.collection('providers').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return ProviderModel.fromMap(doc.data()!, doc.id);
    }
    // Fallback: query by user_id field
    final snap = await _db
        .collection('providers')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return ProviderModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
    }
    return null;
  }

  Future<void> updateProviderProfile(
    String providerId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('providers').doc(providerId).update(data);
  }

  // ─── Bookings ──────────────────────────────────────────────────────────

  Future<String> createBooking(BookingModel booking) async {
    final doc = await _db.collection('bookings').add(booking.toMap());
    return doc.id;
  }

  // No orderBy + where to avoid requiring a Firestore composite index.
  // We sort client-side instead.
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Stream<List<BookingModel>> getProviderBookings(String providerId) {
    return _db
        .collection('bookings')
        .where('provider_id', isEqualTo: providerId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status.name,
    });
  }

  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }
}
