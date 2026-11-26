import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/functional_map.dart';

class AdminEditZoneScreen extends StatefulWidget {
  final FloodZone zone;

  const AdminEditZoneScreen({super.key, required this.zone});

  @override
  State<AdminEditZoneScreen> createState() => _AdminEditZoneScreenState();
}

class _AdminEditZoneScreenState extends State<AdminEditZoneScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _sourceController;
  late RiskLevel _selectedHazardLevel;
  bool _isEditingBoundary = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.zone.name);
    _descController = TextEditingController(text: widget.zone.description);
    _sourceController = TextEditingController(text: widget.zone.dataSource);
    _selectedHazardLevel = widget.zone.hazardLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

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
          'Edit zone',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const AdminScenarioSubheader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Field 1: Zone name
                const Text(
                  'Zone name',
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

                const SizedBox(height: 16),

                // Live Map Boundary preview
                SizedBox(
                  height: 200,
                  child: FunctionalFloodMap(
                    zones: provider.floodZones,
                    selectedZoneId: widget.zone.id,
                    isLiveRiskMode: false,
                    showSavedHomePin: false,
                    showPendingPin: false,
                    showUserLocation: true,
                    onRecenter: () {},
                  ),
                ),

                const SizedBox(height: 10),

                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditingBoundary = !_isEditingBoundary;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isEditingBoundary
                            ? 'Interactive polygon vertex editing enabled'
                            : 'Boundary vertices locked'),
                        backgroundColor: AppColors.primaryTeal,
                      ),
                    );
                  },
                  icon: const Icon(Icons.fullscreen, color: AppColors.primaryTeal, size: 20),
                  label: Text(
                    _isEditingBoundary ? 'Lock boundary on map' : 'Edit boundary on map',
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

                const SizedBox(height: 18),

                // Selector: Long-term hazard level
                const Text(
                  'Long-term hazard level',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _buildHazardOption(RiskLevel.low),
                    const SizedBox(width: 8),
                    _buildHazardOption(RiskLevel.medium),
                    const SizedBox(width: 8),
                    _buildHazardOption(RiskLevel.high),
                  ],
                ),

                const SizedBox(height: 18),

                // Zone description
                const Text(
                  'Zone description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
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

                const SizedBox(height: 18),

                // Data source
                const Text(
                  'Data source',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _sourceController,
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

                const SizedBox(height: 10),
                const Text(
                  'This edits hazard susceptibility, not the live 78% forecast. Last reviewed 01 Jun 2026.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 24),

                // Save zone changes button
                ElevatedButton(
                  onPressed: () {
                    final updated = widget.zone.copyWith(
                      name: _nameController.text.trim(),
                      description: _descController.text.trim(),
                      dataSource: _sourceController.text.trim(),
                      hazardLevel: _selectedHazardLevel,
                    );
                    provider.updateFloodZone(updated);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated zone "${updated.name}"'),
                        backgroundColor: AppColors.primaryTeal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save zone changes',
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

  Widget _buildHazardOption(RiskLevel level) {
    final isSelected = _selectedHazardLevel == level;

    Color bg;
    Color border;
    Color text;

    switch (level) {
      case RiskLevel.low:
        bg = isSelected ? AppColors.riskLowBg : Colors.white;
        border = isSelected ? AppColors.riskLowText : AppColors.surfaceBorder;
        text = isSelected ? AppColors.riskLowText : AppColors.textPrimary;
        break;
      case RiskLevel.medium:
        bg = isSelected ? AppColors.riskMediumBg : Colors.white;
        border = isSelected ? AppColors.riskMediumText : AppColors.surfaceBorder;
        text = isSelected ? AppColors.riskMediumText : AppColors.textPrimary;
        break;
      case RiskLevel.high:
        bg = isSelected ? AppColors.riskHighBg : Colors.white;
        border = isSelected ? AppColors.riskHighText : AppColors.surfaceBorder;
        text = isSelected ? AppColors.riskHighText : AppColors.textPrimary;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedHazardLevel = level;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: isSelected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Icon(Icons.check, size: 16, color: text),
                const SizedBox(width: 4),
              ],
              Text(
                level.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
