import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/colors.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final int? percentage;
  final bool showIcon;

  const RiskBadge({
    super.key,
    required this.level,
    this.percentage,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    IconData icon;

    switch (level) {
      case RiskLevel.low:
        bg = AppColors.riskLowBg;
        border = AppColors.riskLowBorder;
        text = AppColors.riskLowText;
        icon = Icons.verified_user_outlined;
        break;
      case RiskLevel.medium:
        bg = AppColors.riskMediumBg;
        border = AppColors.riskMediumBorder;
        text = AppColors.riskMediumText;
        icon = Icons.error_outline;
        break;
      case RiskLevel.high:
        bg = AppColors.riskHighBg;
        border = AppColors.riskHighBorder;
        text = AppColors.riskHighText;
        icon = Icons.warning_amber_rounded;
        break;
    }

    final label = percentage != null ? '${level.label} · $percentage%' : level.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 14, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PagasaDisclaimerFooter extends StatelessWidget {
  const PagasaDisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 20, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimate only—not an official warning.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening official PAGASA / Local DRRM portal: bagong.pagasa.dost.gov.ph'),
                  duration: Duration(seconds: 3),
                  backgroundColor: AppColors.primaryTeal,
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.open_in_new, size: 14, color: AppColors.primaryTeal),
                SizedBox(width: 4),
                Text(
                  'PAGASA / local DRRM ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
                Text(
                  'View guidance',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScenarioSubheader extends StatelessWidget {
  final String dateText;
  const ScenarioSubheader({super.key, this.dateText = 'Sample scenario · 18 Jun 2026'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F4F2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        dateText,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AdminScenarioSubheader extends StatelessWidget {
  final String text;
  const AdminScenarioSubheader({super.key, this.text = 'ADMIN WORKSPACE · Sample scenario · 18 Jun 2026'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.adminDarkBanner,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
