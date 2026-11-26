import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/functional_map.dart';

class AdminReviewReportScreen extends StatefulWidget {
  final FloodReport report;

  const AdminReviewReportScreen({super.key, required this.report});

  @override
  State<AdminReviewReportScreen> createState() => _AdminReviewReportScreenState();
}

class _AdminReviewReportScreenState extends State<AdminReviewReportScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final report = widget.report;

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
          'Review report',
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
                // Lavender pending status card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.pendingBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.pendingBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: AppColors.pendingText, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pending review\nReceived ${report.timeFormatted}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pendingText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Report summary card
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
                      Text(
                        report.locationArea,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${report.specificLocation} · ${report.waterDepth.descriptiveLabel}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      if (report.note != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '“${report.note!}”',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Photo evidence preview
                if (report.photoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          color: const Color(0xFF6B7280),
                          child: Image.asset(
                            'assets/evidence.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF78909C),
                              child: const Center(
                                child: Icon(Icons.water, color: Colors.white, size: 48),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: const Text(
                            'Sample evidence · not a real incident',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Map location preview
                SizedBox(
                  height: 200,
                  child: FunctionalFloodMap(
                    zones: provider.floodZones,
                    isLiveRiskMode: provider.isLiveRiskMode,
                    showSavedHomePin: false,
                    showPendingPin: false,
                    customPinLabel: 'Report pin',
                    customPinLocation: LatLng(report.latitude, report.longitude),
                    center: LatLng(report.latitude, report.longitude),
                    showUserLocation: true,
                    onRecenter: () {},
                  ),
                ),

                const SizedBox(height: 16),

                // Review note (required to reject)
                const Text(
                  'Review note (required to reject)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Add verification details or reason',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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

                const SizedBox(height: 8),
                const Text(
                  'Approve publishes the observation as a community report, not a change to predicted risk. Reject keeps it off the public map.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),

                const SizedBox(height: 20),

                // Action Row
                Row(
                  children: [
                    // Reject
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final reason = _noteController.text.trim();
                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please add a review note explaining the rejection.'),
                                backgroundColor: AppColors.riskHighText,
                              ),
                            );
                            return;
                          }
                          provider.rejectReport(report.id, reason: reason);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report rejected and excluded from public map.'),
                              backgroundColor: AppColors.riskHighText,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.surfaceBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                            color: AppColors.riskHighText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Approve report
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          provider.approveReport(report.id);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report approved and published!'),
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
                          'Approve report',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
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
