import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/functional_map.dart';

class AdminReviewImportScreen extends StatelessWidget {
  final String fileName;
  final String datasetSource;

  const AdminReviewImportScreen({
    super.key,
    required this.fileName,
    required this.datasetSource,
  });

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
          'Review import',
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
                // Mint Success: File validated
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.mintAccent.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppColors.primaryTeal, size: 20),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'File validated',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '3 zones · no geometry or field errors',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // File Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.description_outlined, color: AppColors.primaryTeal, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                fileName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.check_circle_outline, color: AppColors.riskLowText, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '124 KB · uploaded 18 Jun · 10:28 AM',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Source: $datasetSource',
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Live Map Preview
                SizedBox(
                  height: 200,
                  child: FunctionalFloodMap(
                    zones: provider.floodZones,
                    isLiveRiskMode: false,
                    showSavedHomePin: false,
                    showPendingPin: false,
                    showUserLocation: true,
                    onRecenter: () {},
                  ),
                ),

                const SizedBox(height: 14),

                // Changes to publish Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Changes to publish',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '3 existing zones updated · 0 new · 0 removed',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tumana: High · Concepcion Uno: Medium · Sto. Niño: Low',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  'Publishing updates the long-term layer for residents. Live risk predictions remain unchanged.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),

                const SizedBox(height: 20),

                // Publish hazard update button
                ElevatedButton(
                  onPressed: () {
                    // Trigger import
                    provider.importHazardDataset(datasetSource, provider.floodZones);
                    Navigator.of(context).pop(); // pop review
                    Navigator.of(context).pop(); // pop import screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hazard layer updated successfully across all resident devices!'),
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
                    'Publish hazard update',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 12),

                // Choose another file
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Choose another file',
                    style: TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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
}
