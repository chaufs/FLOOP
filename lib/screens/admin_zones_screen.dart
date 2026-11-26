import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/functional_map.dart';
import 'admin_edit_zone_screen.dart';
import 'admin_import_hazard_screen.dart';

class AdminZonesScreen extends StatelessWidget {
  const AdminZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final zones = provider.floodZones;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Zones',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Long-term hazard management',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const AdminScenarioSubheader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Solid Teal: Import Hazard Data
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminImportHazardScreen()),
                    );
                  },
                  icon: const Icon(Icons.file_upload_outlined, size: 20),
                  label: const Text(
                    'Import hazard data',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),

                const SizedBox(height: 16),

                // Live map in Hazard Susceptibility view (dashed boundaries)
                SizedBox(
                  height: 240,
                  child: FunctionalFloodMap(
                    zones: zones,
                    selectedZoneId: provider.selectedZoneId,
                    isLiveRiskMode: false,
                    showSavedHomePin: false,
                    showPendingPin: false,
                    showUserLocation: true,
                    onZoneTap: (z) {
                      provider.selectZone(z.id);
                    },
                    onRecenter: () {},
                  ),
                ),

                const SizedBox(height: 8),
                const Text(
                  'Hazard susceptibility, not live probability. Sample dataset reviewed 01 Jun 2026.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 16),

                // List of Zone Management Cards
                ...zones.map((zone) => _buildZoneAdminCard(context, provider, zone)),

                const SizedBox(height: 8),
                const Text(
                  'Tap a zone to edit details and hazard level.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
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

  Widget _buildZoneAdminCard(
    BuildContext context,
    AppProvider provider,
    FloodZone zone,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  zone.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          RiskBadge(level: zone.hazardLevel, showIcon: true),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryTeal, size: 20),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AdminEditZoneScreen(zone: zone)),
              );
            },
          ),
        ],
      ),
    );
  }
}
