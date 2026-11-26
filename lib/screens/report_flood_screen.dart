import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/functional_map.dart';

class ReportFloodScreen extends StatefulWidget {
  final FloodZone initialZone;

  const ReportFloodScreen({super.key, required this.initialZone});

  @override
  State<ReportFloodScreen> createState() => _ReportFloodScreenState();
}

class _ReportFloodScreenState extends State<ReportFloodScreen> {
  WaterDepth? _selectedDepth;
  final TextEditingController _noteController = TextEditingController();
  bool _hasPhotoAttached = false;
  String _locationArea = 'Tumana, Marikina';
  final String _specificLocation = 'Near J. P. Rizal St.';
  LatLng _reportPin = const LatLng(14.6540, 121.1010);

  @override
  void initState() {
    super.initState();
    _locationArea = widget.initialZone.name;
    _noteController.text = 'Water covers the road beside the footbridge.';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isSubmitEnabled = _selectedDepth != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Report a flood',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const ScenarioSubheader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Report only what you can safely observe. Never enter floodwater to measure depth.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // Live functional map with report pin
                SizedBox(
                  height: 200,
                  child: FunctionalFloodMap(
                    zones: provider.floodZones,
                    selectedZoneId: widget.initialZone.id,
                    isLiveRiskMode: provider.isLiveRiskMode,
                    showSavedHomePin: false,
                    showPendingPin: false,
                    customPinLabel: 'Report pin',
                    customPinLocation: _reportPin,
                    center: _reportPin,
                    showUserLocation: true,
                    onPinDraggedOrTapped: (point) {
                      setState(() {
                        _reportPin = point;
                        _locationArea = 'Report Location';
                      });
                    },
                    onRecenter: () {},
                  ),
                ),

                const SizedBox(height: 12),

                // Pin location row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primaryTeal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _locationArea,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _specificLocation,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const Text(' · ', style: TextStyle(color: AppColors.textSecondary)),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pin centered on reported coordinates'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Change pin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Water Depth Section *
                Row(
                  children: const [
                    Text(
                      'Water depth',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('*', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),

                // 4 depth option choices in horizontal row
                Row(
                  children: [
                    _buildDepthCard(WaterDepth.ankle),
                    const SizedBox(width: 8),
                    _buildDepthCard(WaterDepth.knee),
                    const SizedBox(width: 8),
                    _buildDepthCard(WaterDepth.waist),
                    const SizedBox(width: 8),
                    _buildDepthCard(WaterDepth.aboveWaist),
                  ],
                ),

                const SizedBox(height: 16),

                // Add photo (optional) button
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasPhotoAttached = !_hasPhotoAttached;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_hasPhotoAttached
                            ? 'Sample street flood evidence photo attached.'
                            : 'Photo removed.'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.primaryTeal,
                      ),
                    );
                  },
                  icon: Icon(
                    _hasPhotoAttached ? Icons.check_circle : Icons.camera_alt_outlined,
                    color: AppColors.primaryTeal,
                    size: 18,
                  ),
                  label: Text(
                    _hasPhotoAttached ? 'Photo attached (1 photo)' : 'Add photo (optional)',
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 16),

                // Note (optional)
                const Text(
                  'Note (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Add details about what you can see',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.all(14),
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

                const SizedBox(height: 14),

                // Dynamic guidance helper text based on selection
                Text(
                  _selectedDepth == null
                      ? 'Choose a depth to enable Submit. Reports are reviewed before appearing publicly.'
                      : '${_selectedDepth!.label} depth selected. Your report will be reviewed before it appears publicly.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 16),

                // Submit report button (Disabled if no depth chosen)
                ElevatedButton(
                  onPressed: isSubmitEnabled
                      ? () {
                          provider.submitResidentReport(
                            locationArea: _locationArea,
                            specificLocation: _specificLocation,
                            waterDepth: _selectedDepth!,
                            note: _noteController.text.trim(),
                            photoUrl: _hasPhotoAttached ? 'sample_evidence.jpg' : null,
                            latitude: _reportPin.latitude,
                            longitude: _reportPin.longitude,
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report submitted! Pin added as pending admin review.'),
                              backgroundColor: AppColors.primaryTeal,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    disabledBackgroundColor: const Color(0xFFD6DFDC),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF6B7280),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit report',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const PagasaDisclaimerFooter(),
        ],
      ),
    );
  }

  Widget _buildDepthCard(WaterDepth depth) {
    final isSelected = _selectedDepth == depth;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDepth = depth;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mintAccent : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryTeal : AppColors.surfaceBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
              ),
              const SizedBox(height: 6),
              Text(
                depth.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
