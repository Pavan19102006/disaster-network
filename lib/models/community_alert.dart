import 'enums.dart';

/// Represents a community alert shared through the mesh network.
class CommunityAlert {
  final String id;
  final String creatorId;
  final String creatorName;
  final AlertCategory category;
  final AlertPriority priority;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int confirmations;
  final int hopCount;

  CommunityAlert({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.category,
    this.priority = AlertPriority.medium,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    DateTime? expiresAt,
    this.confirmations = 0,
    this.hopCount = 0,
  }) : expiresAt = expiresAt ?? createdAt.add(const Duration(hours: 24));

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'creatorId': creatorId,
        'creatorName': creatorName,
        'category': category.name,
        'priority': priority.name,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'confirmations': confirmations,
        'hopCount': hopCount,
      };

  factory CommunityAlert.fromJson(Map<String, dynamic> json) {
    return CommunityAlert(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: (json['creatorName'] as String?) ?? 'Unknown',
      category: AlertCategory.values
          .firstWhere((e) => e.name == json['category']),
      priority: AlertPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AlertPriority.medium,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      confirmations: (json['confirmations'] as int?) ?? 0,
      hopCount: (json['hopCount'] as int?) ?? 0,
    );
  }

  /// Time remaining before expiry
  String get expiryText {
    if (isExpired) return 'Expired';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.inMinutes < 60) return '${remaining.inMinutes}m remaining';
    if (remaining.inHours < 24) return '${remaining.inHours}h remaining';
    return '${remaining.inDays}d remaining';
  }
}
