import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import 'notification_shade_dialog.dart';

class AlertHistoryScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const AlertHistoryScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final history = provider.alertHistory;

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
          'Alert history',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Simulate Push Notification',
            icon: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryTeal),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => NotificationShadeDialog(onNavigateTab: onNavigateTab),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Settings',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const ScenarioSubheader(),
          Expanded(
            child: history.isEmpty ? _buildEmptyHistory(context, provider) : _buildHistoryList(context, provider, history),
          ),
          const PagasaDisclaimerFooter(),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context, AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.mintAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.primaryTeal,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No alerts yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Alerts for your saved places will appear here. An empty history does not mean there is no flood risk.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // Status Card: Flood alerts are on
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
                children: const [
                  Text(
                    'Flood alerts are on',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Icon(Icons.check_circle_outline, color: AppColors.riskLowText, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Threshold: Medium and High',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              const Text(
                'Monitoring Home, School and Work.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Review alert preferences
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.surfaceBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Review alert preferences',
            style: TextStyle(
              color: AppColors.primaryTeal,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Check the flood map
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onNavigateTab?.call(1);
          },
          icon: const Icon(Icons.map_outlined, size: 20),
          label: const Text(
            'Check the flood map',
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
      ],
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    AppProvider provider,
    List<AlertHistoryItem> history,
  ) {
    final todayItems = history.where((i) => i.dateGroup.contains('Today')).toList();
    final earlierItems = history.where((i) => !i.dateGroup.contains('Today')).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recent alerts for your saved places. Open an alert to view its area on the map.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),

        if (todayItems.isNotEmpty) ...[
          const Text(
            'Today · 18 Jun 2026',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...todayItems.map((item) => _buildAlertCard(context, provider, item)),
          const SizedBox(height: 16),
        ],

        if (earlierItems.isNotEmpty) ...[
          const Text(
            'Earlier · 18 Jun 2026',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...earlierItems.map((item) => _buildAlertCard(context, provider, item)),
        ],
      ],
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    AppProvider provider,
    AlertHistoryItem item,
  ) {
    if (item.isProminent) {
      // Prominent High-Risk Red Card (Home in Tumana)
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.riskHighBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.riskHighBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RiskBadge(level: item.riskLevel, percentage: item.riskPercentage),
                Text(
                  item.timeFormatted,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${item.locationName} · ${item.locationArea}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                provider.selectZone('tumana');
                Navigator.of(context).pop();
                onNavigateTab?.call(1);
              },
              icon: const Icon(Icons.map_outlined, color: AppColors.primaryTeal, size: 18),
              label: const Text(
                'Open area on map',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.surfaceBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      );
    }

    // Normal Medium Card
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              RiskBadge(level: item.riskLevel, percentage: item.riskPercentage),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item.locationName} · ${item.locationArea}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.timeFormatted,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            item.message,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              if (item.locationArea.toLowerCase().contains('tumana')) {
                provider.selectZone('tumana');
              } else {
                provider.selectZone('concepcion');
              }
              Navigator.of(context).pop();
              onNavigateTab?.call(1);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'View area on map ',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryTeal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
