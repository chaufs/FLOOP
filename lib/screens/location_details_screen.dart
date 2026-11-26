import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/functional_map.dart';

class LocationDetailsScreen extends StatefulWidget {
  final SavedLocation? existingLocation;
  final bool startInMovePinMode;

  const LocationDetailsScreen({
    super.key,
    this.existingLocation,
    this.startInMovePinMode = false,
  });

  @override
  State<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  String _selectedZoneArea = 'Tumana, Marikina · near J. P. Rizal St.';
  bool _isMovingPin = false;
  LatLng _pinLocation = const LatLng(14.6540, 121.1010);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingLocation?.name ?? 'Home');
    _addressController = TextEditingController(
        text: widget.existingLocation?.address ?? 'Tumana, Marikina City');
    _selectedZoneArea = widget.existingLocation != null
        ? '${widget.existingLocation!.address} · ${widget.existingLocation!.specificLocation}'
        : 'Tumana, Marikina · near J. P. Rizal St.';
    if (widget.existingLocation != null) {
      _pinLocation = LatLng(widget.existingLocation!.latitude, widget.existingLocation!.longitude);
    }
    _isMovingPin = widget.startInMovePinMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isEditing = widget.existingLocation != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isEditing ? 'Edit saved place' : 'Add / edit saved place',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const ScenarioSubheader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Field 1: Location name
                const Text(
                  'Location name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rename this place to something you recognize.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 18),

                // Field 2: Search address or area
                const Text(
                  'Search address or area',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Mini Live Map preview with interactive tap-to-pin
                SizedBox(
                  height: 200,
                  child: FunctionalFloodMap(
                    zones: provider.floodZones,
                    isLiveRiskMode: provider.isLiveRiskMode,
                    showSavedHomePin: false,
                    showPendingPin: false,
                    showUserLocation: true,
                    customPinLabel: widget.existingLocation?.name ?? 'Location Pin',
                    customPinLocation: _pinLocation,
                    center: _pinLocation,
                    interactive: true,
                    onPinDraggedOrTapped: (point) {
                      setState(() {
                        _pinLocation = point;
                        _selectedZoneArea = 'Pin: Lat ${point.latitude.toStringAsFixed(4)}, Lng ${point.longitude.toStringAsFixed(4)}';
                      });
                    },
                    onRecenter: () {},
                  ),
                ),

                const SizedBox(height: 12),

                // Pin location note
                Text(
                  'Pin: $_selectedZoneArea',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                // Move pin button
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isMovingPin = !_isMovingPin;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isMovingPin
                            ? 'Interactive pin dragging activated. Tap on map to relocate.'
                            : 'Pin position set.'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.primaryTeal,
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_with, color: AppColors.primaryTeal, size: 18),
                  label: Text(
                    _isMovingPin ? 'Set pin here' : 'Move pin on map',
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 6),
                const Text(
                  'Drag the pin, then save. For a new place, enter a name and choose its position first.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 24),

                // Primary Save button
                ElevatedButton(
                  onPressed: () {
                    _saveLocation(context, provider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),

                if (isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.deleteSavedLocation(widget.existingLocation!.id);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deleted "${widget.existingLocation!.name}"'),
                          backgroundColor: AppColors.riskHighText,
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, color: AppColors.riskHighText, size: 18),
                    label: const Text(
                      'Delete saved location',
                      style: TextStyle(
                        color: AppColors.riskHighText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const PagasaDisclaimerFooter(),
        ],
      ),
    );
  }

  void _saveLocation(BuildContext context, AppProvider provider) {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location name')),
      );
      return;
    }

    if (widget.existingLocation != null) {
      // Update
      final updated = widget.existingLocation!.copyWith(
        name: name,
        address: address,
        latitude: _pinLocation.latitude,
        longitude: _pinLocation.longitude,
      );
      provider.updateSavedLocation(updated);
    } else {
      // Create new
      final newLoc = SavedLocation(
        id: 'loc_${const Uuid().v4().substring(0, 8)}',
        name: name,
        address: address.isNotEmpty ? address : 'Marikina City',
        specificLocation: 'near pin',
        latitude: _pinLocation.latitude,
        longitude: _pinLocation.longitude,
        riskLevel: RiskLevel.medium,
        riskPercentage: 45,
        predictionReason: 'Moderate risk based on vicinity elevation',
        lastUpdatedTime: '10:30 AM',
      );
      provider.addSavedLocation(newLoc);
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved location "$name"'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }
}
