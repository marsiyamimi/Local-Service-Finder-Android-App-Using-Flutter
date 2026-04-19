class ProviderModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String serviceType;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final double lat;
  final double lng;
  final String? photoUrl;
  final String? address;
  final bool isAvailable;
  final List<String> tags;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.serviceType,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.lat,
    required this.lng,
    this.photoUrl,
    this.address,
    this.isAvailable = true,
    this.tags = const [],
  });

  factory ProviderModel.fromMap(Map<String, dynamic> map, String id) {
    final location = map['location'] as Map<String, dynamic>?;
    return ProviderModel(
      id: id,
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      serviceType: map['service_type'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['review_count'] ?? 0,
      lat: (location?['lat'] ?? 0).toDouble(),
      lng: (location?['lng'] ?? 0).toDouble(),
      photoUrl: map['photoUrl'],
      address: map['address'],
      isAvailable: map['isAvailable'] ?? true,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'service_type': serviceType,
      'description': description,
      'price': price,
      'rating': rating,
      'review_count': reviewCount,
      'location': {'lat': lat, 'lng': lng},
      'photoUrl': photoUrl,
      'address': address,
      'isAvailable': isAvailable,
      'tags': tags,
    };
  }

  String get priceFormatted => '\$${price.toStringAsFixed(0)}/hr';
}

const List<String> serviceCategories = [
  'Plumber',
  'Electrician',
  'Tutor',
  'Cleaner',
  'Carpenter',
  'Painter',
  'Mechanic',
  'Gardener',
  'Security',
  'Driver',
];

const Map<String, String> serviceCategoryIcons = {
  'Plumber': '🔧',
  'Electrician': '⚡',
  'Tutor': '📚',
  'Cleaner': '🧹',
  'Carpenter': '🪚',
  'Painter': '🎨',
  'Mechanic': '🔩',
  'Gardener': '🌿',
  'Security': '🛡️',
  'Driver': '🚗',
};
