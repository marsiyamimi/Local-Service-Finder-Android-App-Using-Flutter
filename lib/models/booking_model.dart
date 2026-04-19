import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, accepted, completed, rejected }

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'accepted':
        return BookingStatus.accepted;
      case 'completed':
        return BookingStatus.completed;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }
}

class BookingModel {
  final String id;
  final String userId;
  final String providerId;
  final String providerName;
  final String serviceType;
  final BookingStatus status;
  final DateTime timestamp;
  final DateTime? scheduledDate;
  final String? userNote;
  final double? price;
  final String? userName;
  final String? userEmail;

  BookingModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.serviceType,
    required this.status,
    required this.timestamp,
    this.scheduledDate,
    this.userNote,
    this.price,
    this.userName,
    this.userEmail,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['user_id'] ?? '',
      providerId: map['provider_id'] ?? '',
      providerName: map['provider_name'] ?? '',
      serviceType: map['service_type'] ?? '',
      status: BookingStatusExtension.fromString(map['status'] ?? 'pending'),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledDate: (map['scheduled_date'] as Timestamp?)?.toDate(),
      userNote: map['user_note'],
      price: (map['price'] as num?)?.toDouble(),
      userName: map['user_name'],
      userEmail: map['user_email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'provider_id': providerId,
      'provider_name': providerName,
      'service_type': serviceType,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'scheduled_date':
          scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'user_note': userNote,
      'price': price,
      'user_name': userName,
      'user_email': userEmail,
    };
  }

  BookingModel copyWith({BookingStatus? status}) {
    return BookingModel(
      id: id,
      userId: userId,
      providerId: providerId,
      providerName: providerName,
      serviceType: serviceType,
      status: status ?? this.status,
      timestamp: timestamp,
      scheduledDate: scheduledDate,
      userNote: userNote,
      price: price,
      userName: userName,
      userEmail: userEmail,
    );
  }

  String get scheduledDateFormatted {
    if (scheduledDate == null) return 'Not scheduled';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = scheduledDate!.hour;
    final m = scheduledDate!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '${scheduledDate!.day} ${months[scheduledDate!.month - 1]} ${scheduledDate!.year} at $hour:$m $period';
  }
}
