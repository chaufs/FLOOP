import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

enum AlertThreshold { mediumAndHigh, highOnly }

enum LocationPermissionState { notDetermined, whileUsingApp, always, denied }

class AppProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final _uuid = const Uuid();

  // --- AUTH & RBAC STATE ---
  AppUser _currentUser = const AppUser(
    uid: 'demo_resident_1',
    email: 'resident@floop.ph',
    displayName: 'Marikina Resident',
    role: UserRole.resident,
  );

  bool get isAdmin => _currentUser.isAdmin;
  bool get isResident => _currentUser.isResident;
  AppUser get currentUser => _currentUser;

  // --- APP STATE FLAGS ---
  bool _isLoading = false;
  bool _isOffline = false;
  LocationPermissionState _permissionState = LocationPermissionState.always;

  // --- MAP SETTINGS ---
  bool _isLiveRiskMode = true; // true = "Risk right now", false = "Flood-prone areas"
  String _selectedZoneId = 'tumana';

  // --- ALERT PREFERENCES ---
  bool _alertsEnabled = true;
  AlertThreshold _alertThreshold = AlertThreshold.mediumAndHigh;
  bool _playAlertSound = true;
  final bool _notificationsAllowed = true;

  // --- SIMULATION DATA ---
  List<SavedLocation> _savedLocations = [];
  List<FloodZone> _floodZones = [];
  List<FloodReport> _reports = [];
  List<AlertHistoryItem> _alertHistory = [];

  // User's temporary pending report (visible only to submitter)
  FloodReport? _myPendingReport;

  // Getters
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  LocationPermissionState get permissionState => _permissionState;
  bool get isLiveRiskMode => _isLiveRiskMode;
  String get selectedZoneId => _selectedZoneId;
  bool get alertsEnabled => _alertsEnabled;
  AlertThreshold get alertThreshold => _alertThreshold;
  bool get playAlertSound => _playAlertSound;
  bool get notificationsAllowed => _notificationsAllowed;

  List<SavedLocation> get savedLocations => _savedLocations;
  List<FloodZone> get floodZones => _floodZones;
  List<FloodReport> get reports => _reports;
  List<FloodReport> get pendingReports =>
      _reports.where((r) => r.status == ReportStatus.pending).toList();
  List<AlertHistoryItem> get alertHistory => _alertHistory;
  FloodReport? get myPendingReport => _myPendingReport;

  FloodZone? get selectedZone {
    try {
      return _floodZones.firstWhere((z) => z.id == _selectedZoneId);
    } catch (_) {
      return _floodZones.isNotEmpty ? _floodZones.first : null;
    }
  }

  AppProvider() {
    _initData();
  }

  void _initData() {
    _floodZones = [
      FloodZone(
        id: 'tumana',
        name: 'Tumana, Marikina',
        shortName: 'TUMANA',
        description: 'River-adjacent residential area',
        liveRiskLevel: RiskLevel.high,
        liveRiskPercentage: 78,
        liveReason: 'Heavy rain expected in the next 3 hours',
        hazardLevel: RiskLevel.high,
        hazardReason: 'High flood susceptibility near the river. This layer does not show today\'s likelihood.',
        dataSource: 'Floop sample hazard dataset v1.0',
        lastReviewedDate: '01 Jun 2026',
        lastUpdatedTime: '18 Jun · 10:25 AM',
        polygonPoints: [
          [0.35, 0.22],
          [0.64, 0.24],
          [0.61, 0.44],
          [0.38, 0.46],
          [0.32, 0.38],
        ],
        geoPoints: [
          const LatLng(14.6575, 121.0965),
          const LatLng(14.6590, 121.1040),
          const LatLng(14.6520, 121.1055),
          const LatLng(14.6500, 121.0980),
          const LatLng(14.6535, 121.0955),
        ],
      ),
      FloodZone(
        id: 'concepcion',
        name: 'Concepcion Uno, Marikina',
        shortName: 'CONCEPCION UNO',
        description: 'Localized drainage constraints',
        liveRiskLevel: RiskLevel.medium,
        liveRiskPercentage: 46,
        liveReason: 'Rain may cause local road flooding',
        hazardLevel: RiskLevel.medium,
        hazardReason: 'Moderate flood risk along Bayan-Bayanan during heavy continuous precipitation.',
        dataSource: 'Floop sample hazard dataset v1.0',
        lastReviewedDate: '01 Jun 2026',
        lastUpdatedTime: '18 Jun · 10:25 AM',
        polygonPoints: [
          [0.62, 0.47],
          [0.95, 0.49],
          [0.92, 0.72],
          [0.57, 0.69],
        ],
        geoPoints: [
          const LatLng(14.6520, 121.1065),
          const LatLng(14.6535, 121.1150),
          const LatLng(14.6460, 121.1165),
          const LatLng(14.6445, 121.1070),
        ],
      ),
      FloodZone(
        id: 'sto_nino',
        name: 'Sto. Niño, Marikina',
        shortName: 'STO. NIÑO',
        description: 'Lower susceptibility zone',
        liveRiskLevel: RiskLevel.low,
        liveRiskPercentage: 12,
        liveReason: 'No significant buildup expected',
        hazardLevel: RiskLevel.low,
        hazardReason: 'Higher ground, efficient gravity drainage.',
        dataSource: 'Floop sample hazard dataset v1.0',
        lastReviewedDate: '01 Jun 2026',
        lastUpdatedTime: '18 Jun · 10:25 AM',
        polygonPoints: [
          [0.28, 0.63],
          [0.55, 0.62],
          [0.55, 0.79],
          [0.28, 0.80],
        ],
        geoPoints: [
          const LatLng(14.6475, 121.0950),
          const LatLng(14.6480, 121.1030),
          const LatLng(14.6415, 121.1040),
          const LatLng(14.6410, 121.0960),
        ],
      ),
    ];

    _savedLocations = [
      SavedLocation(
        id: 'loc_home',
        name: 'Home',
        address: 'Tumana, Marikina',
        specificLocation: 'near J. P. Rizal St.',
        latitude: 14.6540,
        longitude: 121.1010,
        riskLevel: RiskLevel.high,
        riskPercentage: 78,
        predictionReason: 'Heavy rain expected · near the river',
        lastUpdatedTime: '10:25 AM',
      ),
      SavedLocation(
        id: 'loc_school',
        name: 'School',
        address: 'Concepcion Uno, Marikina',
        specificLocation: 'near Bayan-Bayanan Ave.',
        latitude: 14.6515,
        longitude: 121.1090,
        riskLevel: RiskLevel.medium,
        riskPercentage: 46,
        predictionReason: 'Rain may cause local road flooding',
        lastUpdatedTime: '10:25 AM',
      ),
      SavedLocation(
        id: 'loc_work',
        name: 'Work',
        address: 'Sto. Niño, Marikina',
        specificLocation: 'commercial strip',
        latitude: 14.6430,
        longitude: 121.1020,
        riskLevel: RiskLevel.low,
        riskPercentage: 12,
        predictionReason: 'No significant buildup expected',
        lastUpdatedTime: '10:25 AM',
      ),
    ];

    _reports = [
      FloodReport(
        id: 'rep_1',
        locationArea: 'Tumana, Marikina',
        specificLocation: 'Near J. P. Rizal St.',
        waterDepth: WaterDepth.knee,
        note: 'Water covers the road beside the footbridge.',
        photoUrl: 'sample_evidence.jpg',
        submittedAt: DateTime(2026, 6, 18, 10, 18),
        timeFormatted: '18 Jun · 10:18 AM',
        status: ReportStatus.pending,
        latitude: 14.6540,
        longitude: 121.1010,
      ),
      FloodReport(
        id: 'rep_2',
        locationArea: 'Concepcion Uno, Marikina',
        specificLocation: 'Bayan-Bayanan corner',
        waterDepth: WaterDepth.ankle,
        note: 'Pooling at the street corner. No photo attached.',
        photoUrl: null,
        submittedAt: DateTime(2026, 6, 18, 10, 12),
        timeFormatted: '18 Jun · 10:12 AM',
        status: ReportStatus.pending,
        latitude: 14.6515,
        longitude: 121.1090,
      ),
    ];

    _alertHistory = [
      AlertHistoryItem(
        id: 'alt_1',
        locationName: 'Home',
        locationArea: 'Tumana, Marikina',
        riskLevel: RiskLevel.high,
        riskPercentage: 78,
        timeFormatted: '10:30 AM',
        dateGroup: 'Today · 18 Jun 2026',
        message: 'Heavy rain expected in the next 3 hours. Avoid low-lying roads and prepare to move to higher ground.',
        isProminent: true,
      ),
      AlertHistoryItem(
        id: 'alt_2',
        locationName: 'School',
        locationArea: 'Concepcion Uno, Marikina',
        riskLevel: RiskLevel.medium,
        riskPercentage: 46,
        timeFormatted: '18 Jun 2026 · 10:30 AM',
        dateGroup: 'Today · 18 Jun 2026',
        message: 'Rain may cause local road flooding.',
        isProminent: false,
      ),
      AlertHistoryItem(
        id: 'alt_3',
        locationName: 'Home',
        locationArea: 'Tumana, Marikina',
        riskLevel: RiskLevel.medium,
        riskPercentage: 52,
        timeFormatted: '18 Jun 2026 · 9:00 AM',
        dateGroup: 'Earlier · 18 Jun 2026',
        message: 'Rainfall increasing near the river.',
        isProminent: false,
      ),
    ];
  }

  // --- AUTH & RBAC SWITCHERS ---
  void switchUserRole(UserRole role) {
    if (role == UserRole.admin) {
      _currentUser = const AppUser(
        uid: 'admin_marikina_drrm',
        email: 'admin.drrm@marikina.gov.ph',
        displayName: 'Engr. DRRM Admin',
        role: UserRole.admin,
      );
    } else {
      _currentUser = const AppUser(
        uid: 'demo_resident_1',
        email: 'resident@floop.ph',
        displayName: 'Marikina Resident',
        role: UserRole.resident,
      );
    }
    notifyListeners();
  }

  Future<void> signInUser(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _firebaseService.signInWithEmailPassword(email, password);
      if (user != null) {
        _currentUser = user;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void signOutUser() {
    _firebaseService.signOut();
    _currentUser = const AppUser(
      uid: 'demo_resident_1',
      email: 'resident@floop.ph',
      displayName: 'Marikina Resident',
      role: UserRole.resident,
    );
    notifyListeners();
  }

  // State switchers
  void toggleLiveRiskMode(bool live) {
    _isLiveRiskMode = live;
    notifyListeners();
  }

  void selectZone(String zoneId) {
    _selectedZoneId = zoneId;
    notifyListeners();
  }

  void setOffline(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setPermissionState(LocationPermissionState state) {
    _permissionState = state;
    notifyListeners();
  }

  // Location CRUD
  void addSavedLocation(SavedLocation loc) {
    _savedLocations.add(loc);
    _firebaseService.syncSavedLocation(loc, _currentUser.uid);
    notifyListeners();
  }

  void updateSavedLocation(SavedLocation updated) {
    final idx = _savedLocations.indexWhere((l) => l.id == updated.id);
    if (idx != -1) {
      _savedLocations[idx] = updated;
      _firebaseService.syncSavedLocation(updated, _currentUser.uid);
      notifyListeners();
    }
  }

  void deleteSavedLocation(String id) {
    _savedLocations.removeWhere((l) => l.id == id);
    _firebaseService.deleteSavedLocation(id, _currentUser.uid);
    notifyListeners();
  }

  void clearAllLocations() {
    _savedLocations.clear();
    notifyListeners();
  }

  void restoreDemoLocations() {
    _initData();
    notifyListeners();
  }

  // Alert preferences
  void updateAlertPreferences({
    required bool enabled,
    required AlertThreshold threshold,
    required bool playSound,
  }) {
    _alertsEnabled = enabled;
    _alertThreshold = threshold;
    _playAlertSound = playSound;
    notifyListeners();
  }

  void clearAlertHistory() {
    _alertHistory.clear();
    notifyListeners();
  }

  // Report submission
  void submitResidentReport({
    required String locationArea,
    required String specificLocation,
    required WaterDepth waterDepth,
    String? note,
    String? photoUrl,
    double latitude = 14.6540,
    double longitude = 121.1010,
  }) {
    final report = FloodReport(
      id: 'rep_${_uuid.v4().substring(0, 8)}',
      locationArea: locationArea,
      specificLocation: specificLocation,
      waterDepth: waterDepth,
      note: note,
      photoUrl: photoUrl,
      submittedAt: DateTime.now(),
      timeFormatted: '18 Jun · 10:30 AM',
      status: ReportStatus.pending,
      latitude: latitude,
      longitude: longitude,
    );

    _reports.insert(0, report);
    _myPendingReport = report;
    _firebaseService.submitReport(report);
    notifyListeners();
  }

  void clearPendingReportView() {
    _myPendingReport = null;
    notifyListeners();
  }

  // Admin Actions (RBAC guarded: requires isAdmin)
  bool approveReport(String id) {
    if (!isAdmin) return false;
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reports[idx] = _reports[idx].copyWith(status: ReportStatus.approved);
      _firebaseService.updateReportStatus(id, ReportStatus.approved);
      if (_myPendingReport?.id == id) {
        _myPendingReport = _reports[idx];
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  bool rejectReport(String id, {String? reason}) {
    if (!isAdmin) return false;
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reports[idx] = _reports[idx].copyWith(
        status: ReportStatus.rejected,
        rejectionReason: reason ?? 'Did not meet verification criteria',
      );
      _firebaseService.updateReportStatus(id, ReportStatus.rejected, rejectionReason: reason);
      if (_myPendingReport?.id == id) {
        _myPendingReport = null;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearAdminQueue() {
    if (!isAdmin) return;
    _reports.removeWhere((r) => r.status == ReportStatus.pending);
    notifyListeners();
  }

  // Zone Management (Admin Only)
  bool updateFloodZone(FloodZone updated) {
    if (!isAdmin) return false;
    final idx = _floodZones.indexWhere((z) => z.id == updated.id);
    if (idx != -1) {
      _floodZones[idx] = updated;
      _firebaseService.syncFloodZone(updated);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool importHazardDataset(String sourceName, List<FloodZone> newZones) {
    if (!isAdmin) return false;
    for (final newZone in newZones) {
      final idx = _floodZones.indexWhere((z) => z.id == newZone.id);
      if (idx != -1) {
        _floodZones[idx] = newZone;
        _firebaseService.syncFloodZone(newZone);
      } else {
        _floodZones.add(newZone);
        _firebaseService.syncFloodZone(newZone);
      }
    }
    notifyListeners();
    return true;
  }
}
