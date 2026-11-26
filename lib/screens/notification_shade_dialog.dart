import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';

class NotificationShadeDialog extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const NotificationShadeDialog({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EDE9), // Android shade wallpaper tint
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top lockscreen header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Sample Android notification',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Row(
                  children: [
                    Icon(Icons.wifi, size: 16, color: AppColors.textPrimary),
                    SizedBox(width: 4),
                    Icon(Icons.battery_full, size: 16, color: AppColors.textPrimary),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '10:30',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Thursday, 18 June 2026',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Quick setting tiles (Wifi, Sound, BT, Flashlight)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickTile(Icons.wifi, isActive: true),
                _buildQuickTile(Icons.volume_up, isActive: true),
                _buildQuickTile(Icons.bluetooth, isActive: false),
                _buildQuickTile(Icons.flashlight_on, isActive: false),
              ],
            ),
            const SizedBox(height: 20),

            // The Floop Notification Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.waves, color: AppColors.primaryTeal, size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'Floop · now · Sample alert',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_up, size: 18, color: AppColors.textMuted),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const RiskBadge(level: RiskLevel.high, percentage: 78),
                  const SizedBox(height: 10),
                  const Text(
                    'Home · Tumana, Marikina',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'High flood risk in your area in the next 3 hours. Avoid low-lying roads and prepare to move to higher ground.',
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Estimate only—not an official warning.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),

                  // Open Tumana on map button
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.selectZone('tumana');
                      Navigator.of(context).pop();
                      onNavigateTab?.call(1);
                    },
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text(
                      'Open Tumana on map',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: const Size(double.infinity, 44),
                      elevation: 0,
                    ),
                  ),

                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening official PAGASA portal')),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.open_in_new, size: 14, color: AppColors.primaryTeal),
                        SizedBox(width: 4),
                        Text(
                          'PAGASA / local DRRM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Manage notifications',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Clear all',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Illustrative scenario only. This is not a current flood warning.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTile(IconData icon, {required bool isActive}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryTeal : Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : AppColors.textPrimary,
        size: 20,
      ),
    );
  }
}
