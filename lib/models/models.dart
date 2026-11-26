import 'package:latlong2/latlong.dart';
export 'user_model.dart';

enum RiskLevel { low, medium, high }

extension RiskLevelExtension on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }

  static RiskLevel fromString(String val) {
    switch (val.toLowerCase()) {
      case 'high':
        return RiskLevel.high;
      case 'medium':
        return RiskLevel.medium;
      case 'low':
      default:
        return RiskLevel.low;
    }
  }
}

class SavedLocation {
  final String id;
  final String name; // e.g. "Home", "School", "Work"
  final String address; // e.g. "Tumana, Marikina"
  final String specificLocation; // e.g. "near J. P. Rizal St."
  final double latitude;
  final double longitude;
  final RiskLevel riskLevel;
  final int riskPercentage; // e.g. 78
  final String predictionReason; // e.g. "Heavy rain expected · near the river"
  final String lastUpdatedTime; // e.g. "10:25 AM"

  SavedLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.specificLocation,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.riskPercentage,
    required this.predictionReason,
    required this.lastUpdatedTime,
  });

  SavedLocation copyWith({
    String? id,
    String? name,
    String? address,
    String? specificLocation,
    double? latitude,
    double? longitude,
    RiskLevel? riskLevel,
    int? riskPercentage,
    String? predictionReason,
    String? lastUpdatedTime,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      specificLocation: specificLocation ?? this.specificLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      riskLevel: riskLevel ?? this.riskLevel,
      riskPercentage: riskPercentage ?? this.riskPercentage,
      predictionReason: predictionReason ?? this.predictionReason,
      lastUpdatedTime: lastUpdatedTime ?? this.lastUpdatedTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'specificLocation': specificLocation,
      'latitude': latitude,
      'longitude': longitude,
      'riskLevel': riskLevel.name,
      'riskPercentage': riskPercentage,
      'predictionReason': predictionReason,
      'lastUpdatedTime': lastUpdatedTime,
    };
  }

  factory SavedLocation.fromMap(Map<String, dynamic> map, String id) {
    return SavedLocation(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      specificLocation: map['specificLocation'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 14.6507,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 121.1029,
      riskLevel: RiskLevelExtension.fromString(map['riskLevel'] ?? 'low'),
      riskPercentage: (map['riskPercentage'] as num?)?.toInt() ?? 0,
      predictionReason: map['predictionReason'] ?? '',
      lastUpdatedTime: map['lastUpdatedTime'] ?? '10:25 AM',
    );
  }
}

class FloodZone {
  final String id;
  final String name; // e.g. "Tumana, Marikina"
  final String shortName; // e.g. "TUMANA"
  final String description; // e.g. "River-adjacent residential area"
  final RiskLevel liveRiskLevel;
  final int liveRiskPercentage; // e.g. 78%
  final String liveReason; // e.g. "Heavy rain expected in the next 3 hours"
  final RiskLevel hazardLevel; // Long-term hazard: High, Medium, Low
  final String hazardReason; // e.g. "High flood susceptibility near the river..."
  final String dataSource; // e.g. "Floop sample hazard dataset v1.0"
  final String lastReviewedDate; // e.g. "01 Jun 2026"
  final String lastUpdatedTime; // e.g. "18 Jun · 10:25 AM"
  // Real geographic boundary coordinates for the zone (latitude & longitude)
  final List<LatLng> geoPoints;
  // Normalized points fallback for mini illustrative canvas
  final List<List<double>> polygonPoints;

  FloodZone({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.liveRiskLevel,
    required this.liveRiskPercentage,
    required this.liveReason,
    required this.hazardLevel,
    required this.hazardReason,
    required this.dataSource,
    required this.lastReviewedDate,
    required this.lastUpdatedTime,
    required this.polygonPoints,
    required this.geoPoints,
  });

  FloodZone copyWith({
    String? id,
    String? name,
    String? shortName,
    String? description,
    RiskLevel? liveRiskLevel,
    int? liveRiskPercentage,
    String? liveReason,
    RiskLevel? hazardLevel,
    String? hazardReason,
    String? dataSource,
    String? lastReviewedDate,
    String? lastUpdatedTime,
    List<List<double>>? polygonPoints,
    List<LatLng>? geoPoints,
  }) {
    return FloodZone(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      liveRiskLevel: liveRiskLevel ?? this.liveRiskLevel,
      liveRiskPercentage: liveRiskPercentage ?? this.liveRiskPercentage,
      liveReason: liveReason ?? this.liveReason,
      hazardLevel: hazardLevel ?? this.hazardLevel,
      hazardReason: hazardReason ?? this.hazardReason,
      dataSource: dataSource ?? this.dataSource,
      lastReviewedDate: lastReviewedDate ?? this.lastReviewedDate,
      lastUpdatedTime: lastUpdatedTime ?? this.lastUpdatedTime,
      polygonPoints: polygonPoints ?? this.polygonPoints,
      geoPoints: geoPoints ?? this.geoPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'description': description,
      'liveRiskLevel': liveRiskLevel.name,
      'liveRiskPercentage': liveRiskPercentage,
      'liveReason': liveReason,
      'hazardLevel': hazardLevel.name,
      'hazardReason': hazardReason,
      'dataSource': dataSource,
      'lastReviewedDate': lastReviewedDate,
      'lastUpdatedTime': lastUpdatedTime,
      'geoPoints': geoPoints.map((p) => [p.latitude, p.longitude]).toList(),
    };
  }

  factory FloodZone.fromMap(Map<String, dynamic> map, String id, {List<List<double>>? points, List<LatLng>? geoPoints}) {
    List<LatLng> parsedGeo = [];
    if (map['geoPoints'] != null && map['geoPoints'] is List) {
      for (final pt in map['geoPoints']) {
        if (pt is List && pt.length >= 2) {
          parsedGeo.add(LatLng((pt[0] as num).toDouble(), (pt[1] as num).toDouble()));
        }
      }
    }
    return FloodZone(
      id: id,
      name: map['name'] ?? '',
      shortName: map['shortName'] ?? '',
      description: map['description'] ?? '',
      liveRiskLevel: RiskLevelExtension.fromString(map['liveRiskLevel'] ?? 'low'),
      liveRiskPercentage: (map['liveRiskPercentage'] as num?)?.toInt() ?? 0,
      liveReason: map['liveReason'] ?? '',
      hazardLevel: RiskLevelExtension.fromString(map['hazardLevel'] ?? 'low'),
      hazardReason: map['hazardReason'] ?? '',
      dataSource: map['dataSource'] ?? 'Floop hazard dataset',
      lastReviewedDate: map['lastReviewedDate'] ?? '01 Jun 2026',
      lastUpdatedTime: map['lastUpdatedTime'] ?? '18 Jun · 10:25 AM',
      polygonPoints: points ?? [],
      geoPoints: parsedGeo.isNotEmpty ? parsedGeo : (geoPoints ?? []),
    );
  }
}

enum WaterDepth { ankle, knee, waist, aboveWaist }

extension WaterDepthExtension on WaterDepth {
  String get label {
    switch (this) {
      case WaterDepth.ankle:
        return 'Ankle';
      case WaterDepth.knee:
        return 'Knee';
      case WaterDepth.waist:
        return 'Waist';
      case WaterDepth.aboveWaist:
        return 'Above waist';
    }
  }

  String get descriptiveLabel {
    switch (this) {
      case WaterDepth.ankle:
        return 'Ankle depth';
      case WaterDepth.knee:
        return 'Knee-deep water';
      case WaterDepth.waist:
        return 'Waist-deep water';
      case WaterDepth.aboveWaist:
        return 'Above waist depth';
    }
  }

  static WaterDepth fromString(String val) {
    switch (val.toLowerCase()) {
      case 'ankle':
        return WaterDepth.ankle;
      case 'knee':
        return WaterDepth.knee;
      case 'waist':
        return WaterDepth.waist;
      case 'abovewaist':
      case 'above waist':
      default:
        return WaterDepth.aboveWaist;
    }
  }
}

enum ReportStatus { pending, approved, rejected }

class FloodReport {
  final String id;
  final String locationArea; // e.g. "Tumana, Marikina"
  final String specificLocation; // e.g. "Near J. P. Rizal St."
  final WaterDepth waterDepth;
  final String? note; // e.g. "Water covers the road beside the footbridge."
  final String? photoUrl; // URL or asset path
  final DateTime submittedAt;
  final String timeFormatted; // e.g. "18 Jun · 10:18 AM"
  final ReportStatus status;
  final String? rejectionReason;
  final double latitude;
  final double longitude;

  FloodReport({
    required this.id,
    required this.locationArea,
    required this.specificLocation,
    required this.waterDepth,
    this.note,
    this.photoUrl,
    required this.submittedAt,
    required this.timeFormatted,
    this.status = ReportStatus.pending,
    this.rejectionReason,
    this.latitude = 14.6507,
    this.longitude = 121.1029,
  });

  FloodReport copyWith({
    String? id,
    String? locationArea,
    String? specificLocation,
    WaterDepth? waterDepth,
    String? note,
    String? photoUrl,
    DateTime? submittedAt,
    String? timeFormatted,
    ReportStatus? status,
    String? rejectionReason,
    double? latitude,
    double? longitude,
  }) {
    return FloodReport(
      id: id ?? this.id,
      locationArea: locationArea ?? this.locationArea,
      specificLocation: specificLocation ?? this.specificLocation,
      waterDepth: waterDepth ?? this.waterDepth,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
      submittedAt: submittedAt ?? this.submittedAt,
      timeFormatted: timeFormatted ?? this.timeFormatted,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'locationArea': locationArea,
      'specificLocation': specificLocation,
      'waterDepth': waterDepth.name,
      'note': note,
      'photoUrl': photoUrl,
      'submittedAt': submittedAt.toIso8601String(),
      'timeFormatted': timeFormatted,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory FloodReport.fromMap(Map<String, dynamic> map, String id) {
    return FloodReport(
      id: id,
      locationArea: map['locationArea'] ?? '',
      specificLocation: map['specificLocation'] ?? '',
      waterDepth: WaterDepthExtension.fromString(map['waterDepth'] ?? 'knee'),
      note: map['note'],
      photoUrl: map['photoUrl'],
      submittedAt: DateTime.tryParse(map['submittedAt'] ?? '') ?? DateTime.now(),
      timeFormatted: map['timeFormatted'] ?? '18 Jun · 10:18 AM',
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      rejectionReason: map['rejectionReason'],
      latitude: (map['latitude'] as num?)?.toDouble() ?? 14.6507,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 121.1029,
    );
  }
}

class AlertHistoryItem {
  final String id;
  final String locationName; // "Home"
  final String locationArea; // "Tumana, Marikina"
  final RiskLevel riskLevel;
  final int riskPercentage;
  final String timeFormatted; // "10:30 AM" or "18 Jun 2026 · 10:30 AM"
  final String dateGroup; // "Today · 18 Jun 2026" or "Earlier · 18 Jun 2026"
  final String message; // "Heavy rain expected in the next 3 hours..."
  final bool isProminent; // Red prominent card vs standard

  AlertHistoryItem({
    required this.id,
    required this.locationName,
    required this.locationArea,
    required this.riskLevel,
    required this.riskPercentage,
    required this.timeFormatted,
    required this.dateGroup,
    required this.message,
    this.isProminent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'locationName': locationName,
      'locationArea': locationArea,
      'riskLevel': riskLevel.name,
      'riskPercentage': riskPercentage,
      'timeFormatted': timeFormatted,
      'dateGroup': dateGroup,
      'message': message,
      'isProminent': isProminent,
    };
  }

  factory AlertHistoryItem.fromMap(Map<String, dynamic> map, String id) {
    return AlertHistoryItem(
      id: id,
      locationName: map['locationName'] ?? '',
      locationArea: map['locationArea'] ?? '',
      riskLevel: RiskLevelExtension.fromString(map['riskLevel'] ?? 'medium'),
      riskPercentage: (map['riskPercentage'] as num?)?.toInt() ?? 50,
      timeFormatted: map['timeFormatted'] ?? '',
      dateGroup: map['dateGroup'] ?? 'Today · 18 Jun 2026',
      message: map['message'] ?? '',
      isProminent: map['isProminent'] ?? false,
    );
  }
}
