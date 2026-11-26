import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/functional_map.dart';
import 'report_flood_screen.dart';

class FloodMapScreen extends StatelessWidget {
  const FloodMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isLive = provider.isLiveRiskMode;
    final selectedZone = provider.selectedZone;
    final isOffline = provider.isOffline;
    final pendingReport = provider.myPendingReport;

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
              'Flood map',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Marikina City',
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
          const ScenarioSubheader(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Offline Banner (if offline)
                if (isOffline) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.riskMediumBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.riskMediumBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.wifi_off, color: AppColors.riskMediumText, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Offline · showing last known data',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Last updated 18 Jun 2026 · 10:25 AM. Current conditions may have changed.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 2. Pending Review Banner (if user recently submitted report)
                if (pendingReport != null && !isOffline) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.pendingBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.pendingBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.access_time_filled, color: AppColors.pendingText, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Report sent · pending review',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Only you can see this pending pin. It does not change the flood prediction.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. Segmented Mode Switcher: [ Flood-prone areas ] | [ ✓ Risk right now ]
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      // Flood-prone areas
                      Expanded(
                        child: GestureDetector(
                          onTap: () => provider.toggleLiveRiskMode(false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !isLive ? AppColors.mintAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!isLive) const Icon(Icons.check, size: 16, color: AppColors.primaryTeal),
                                if (!isLive) const SizedBox(width: 4),
                                Text(
                                  'Flood-prone areas',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: !isLive ? FontWeight.bold : FontWeight.w500,
                                    color: !isLive ? AppColors.primaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Risk right now
                      Expanded(
                        child: GestureDetector(
                          onTap: () => provider.toggleLiveRiskMode(true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLive ? AppColors.mintAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLive) const Icon(Icons.check, size: 16, color: AppColors.primaryTeal),
                                if (isLive) const SizedBox(width: 4),
                                Text(
                                  'Risk right now',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isLive ? FontWeight.bold : FontWeight.w500,
                                    color: isLive ? AppColors.primaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Hazard layer notification info box (when in "Flood-prone areas" mode)
                if (!isLive) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.mintAccent.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline, color: AppColors.primaryTeal, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Long-term hazard, not live risk',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Dashed boundaries show flood-prone areas. Switch modes for the next 3 hours.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 5. Interactive Live Map (OpenStreetMap with Zone Polygons)
                SizedBox(
                  height: 310,
                  child: FunctionalFloodMap(
                    zones: provider.floodZones,
                    selectedZoneId: provider.selectedZoneId,
                    isLiveRiskMode: isLive,
                    showSavedHomePin: true,
                    showPendingPin: pendingReport != null,
                    showUserLocation: provider.permissionState != LocationPermissionState.denied,
                    onZoneTap: (z) {
                      provider.selectZone(z.id);
                    },
                    onRecenter: () {
                      provider.selectZone('tumana');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Re-centered on user location (Tumana, Marikina)'),
                          duration: Duration(seconds: 2),
                          backgroundColor: AppColors.primaryTeal,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 6. Legend Chips & Subtitle
                Row(
                  children: const [
                    RiskBadge(level: RiskLevel.low),
                    SizedBox(width: 8),
                    RiskBadge(level: RiskLevel.medium),
                    SizedBox(width: 8),
                    RiskBadge(level: RiskLevel.high),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isLive
                      ? 'Live flood probability · next 3 hours'
                      : 'Long-term flood susceptibility · not a probability',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 16),

                // 7. Bottom Card for Selected Zone
                _buildZoneCard(context, provider, selectedZone, isLive, isOffline, pendingReport),
              ],
            ),
          ),

          const PagasaDisclaimerFooter(),
        ],
      ),
    );
  }

  Widget _buildZoneCard(
    BuildContext context,
    AppProvider provider,
    FloodZone? zone,
    bool isLive,
    bool isOffline,
    FloodReport? pendingReport,
  ) {
    if (zone == null) return const SizedBox.shrink();

    // If viewing user's pending report card
    if (pendingReport != null && !isOffline) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your report · Tumana, Marikina',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${pendingReport.waterDepth.descriptiveLabel} · submitted 10:30 AM',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.access_time, size: 16, color: AppColors.pendingText),
                SizedBox(width: 6),
                Text(
                  'Pending admin review',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pendingText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'We\'ll notify you after review. Do not wait for approval if you need to move to safety.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                provider.clearPendingReportView();
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.surfaceBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Back to live risk',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal zone card or offline card
    final isHome = zone.id == 'tumana';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOffline ? AppColors.riskMediumBg.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOffline ? AppColors.riskMediumBorder : AppColors.surfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name + (isHome ? ' · Home' : ''),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOffline
                          ? ''
                          : (isLive
                              ? (isHome ? 'Home · next 3 hours' : 'next 3 hours')
                              : 'Long-term hazard layer'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              RiskBadge(
                level: isLive ? zone.liveRiskLevel : zone.hazardLevel,
                percentage: isLive ? zone.liveRiskPercentage : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isOffline) ...[
            const Text(
              'Last known estimate, not a live update.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Heavy rain was expected in the next 3 hours at the last update.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ] else ...[
            Text(
              isLive ? zone.liveReason : zone.hazardReason,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isLive ? 'Last updated ${zone.lastUpdatedTime}' : 'Sample hazard dataset · reviewed ${zone.lastReviewedDate}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (isOffline) ...[
            ElevatedButton.icon(
              onPressed: () {
                provider.setOffline(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reconnected! Live predictions synced.'),
                    backgroundColor: AppColors.primaryTeal,
                  ),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Try reconnecting',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'New reports can\'t be submitted while offline. For current safety advice, check PAGASA or your local DRRM when connected.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportFloodScreen(initialZone: zone),
                  ),
                );
              },
              icon: const Icon(Icons.outlined_flag, size: 20),
              label: const Text(
                'Report flood here',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
