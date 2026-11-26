import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';
import '../theme/colors.dart';

class FunctionalFloodMap extends StatefulWidget {
  final List<FloodZone> zones;
  final String? selectedZoneId;
  final bool isLiveRiskMode;
  final Function(FloodZone)? onZoneTap;
  final bool showSavedHomePin;
  final bool showPendingPin;
  final bool showUserLocation;
  final String? customPinLabel;
  final LatLng? customPinLocation;
  final Function(LatLng)? onPinDraggedOrTapped;
  final VoidCallback? onRecenter;
  final bool interactive;
  final LatLng? center;
  final double zoom;

  const FunctionalFloodMap({
    super.key,
    required this.zones,
    this.selectedZoneId,
    required this.isLiveRiskMode,
    this.onZoneTap,
    this.showSavedHomePin = true,
    this.showPendingPin = false,
    this.showUserLocation = true,
    this.customPinLabel,
    this.customPinLocation,
    this.onPinDraggedOrTapped,
    this.onRecenter,
    this.interactive = true,
    this.center,
    this.zoom = 14.2,
  });

  @override
  State<FunctionalFloodMap> createState() => _FunctionalFloodMapState();
}

class _FunctionalFloodMapState extends State<FunctionalFloodMap> {
  late final MapController _mapController;
  final LatLng _marikinaCenter = const LatLng(14.6507, 121.1029);
  late LatLng _currentPinLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentPinLocation = widget.customPinLocation ?? const LatLng(14.6540, 121.1010);
  }

  @override
  void didUpdateWidget(covariant FunctionalFloodMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customPinLocation != null &&
        widget.customPinLocation != oldWidget.customPinLocation) {
      _currentPinLocation = widget.customPinLocation!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.center ?? _marikinaCenter,
              initialZoom: widget.zoom,
              minZoom: 11.0,
              maxZoom: 18.0,
              interactionOptions: InteractionOptions(
                flags: widget.interactive
                    ? InteractiveFlag.all
                    : InteractiveFlag.none,
              ),
              onTap: (tapPosition, point) {
                if (widget.onPinDraggedOrTapped != null) {
                  setState(() {
                    _currentPinLocation = point;
                  });
                  widget.onPinDraggedOrTapped!(point);
                }
              },
            ),
            children: [
              // Live OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.floop.granadafinalproject',
                maxZoom: 19,
              ),

              // Flood Zones Polygon Overlays
              PolygonLayer(
                polygons: widget.zones.map((zone) {
                  final isSelected = zone.id == widget.selectedZoneId;
                  final level = widget.isLiveRiskMode ? zone.liveRiskLevel : zone.hazardLevel;

                  Color fillColor;
                  Color borderColor;

                  switch (level) {
                    case RiskLevel.high:
                      fillColor = AppColors.riskHighFill;
                      borderColor = const Color(0xFFC62828);
                      break;
                    case RiskLevel.medium:
                      fillColor = AppColors.riskMediumFill;
                      borderColor = const Color(0xFFC66900);
                      break;
                    case RiskLevel.low:
                      fillColor = AppColors.riskLowFill;
                      borderColor = const Color(0xFF2E7D32);
                      break;
                  }

                  return Polygon(
                    points: zone.geoPoints,
                    color: fillColor,
                    borderColor: borderColor,
                    borderStrokeWidth: isSelected ? 3.0 : 1.8,
                  );
                }).toList(),
              ),

              // Markers Layer: Zone Labels, Saved Places, User Location, Pending Pin
              MarkerLayer(
                markers: [
                  // Zone Centroid Labels
                  ...widget.zones.map((zone) {
                    if (zone.geoPoints.isEmpty) return null;
                    // Compute centroid
                    double sumLat = 0;
                    double sumLng = 0;
                    for (final p in zone.geoPoints) {
                      sumLat += p.latitude;
                      sumLng += p.longitude;
                    }
                    final centroid = LatLng(sumLat / zone.geoPoints.length, sumLng / zone.geoPoints.length);

                    return Marker(
                      point: centroid,
                      width: 110,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => widget.onZoneTap?.call(zone),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: zone.id == widget.selectedZoneId
                                  ? AppColors.primaryTeal
                                  : Colors.black12,
                              width: zone.id == widget.selectedZoneId ? 1.5 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              zone.shortName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).whereType<Marker>(),

                  // Saved Home Pin
                  if (widget.showSavedHomePin && !widget.showPendingPin && widget.customPinLabel == null)
                    Marker(
                      point: const LatLng(14.6540, 121.1010), // Tumana coordinates
                      width: 50,
                      height: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryTeal,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.home, color: Colors.white, size: 20),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Pending Review Pin
                  if (widget.showPendingPin)
                    Marker(
                      point: const LatLng(14.6540, 121.1010),
                      width: 60,
                      height: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.pendingText,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.access_time_filled, color: Colors.white, size: 20),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pendingText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Custom / Interactive Move Pin
                  if (widget.customPinLabel != null)
                    Marker(
                      point: _currentPinLocation,
                      width: 70,
                      height: 65,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryTeal,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.location_on, color: Colors.white, size: 22),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.customPinLabel!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // User Location Pulse Dot
                  if (widget.showUserLocation)
                    Marker(
                      point: const LatLng(14.6515, 121.1090),
                      width: 26,
                      height: 26,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Scale indicator bottom-left
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black12),
              ),
              child: const Text(
                'Live Map · OpenStreetMap · 200 m',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          // Re-center Floating button bottom-right
          if (widget.interactive)
            Positioned(
              right: 12,
              bottom: 12,
              child: InkWell(
                onTap: () {
                  _mapController.move(_marikinaCenter, 14.2);
                  widget.onRecenter?.call();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.primaryTeal,
                    size: 22,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
