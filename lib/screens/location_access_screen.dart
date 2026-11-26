import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';

class LocationAccessScreen extends StatelessWidget {
  const LocationAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDenied = provider.permissionState == LocationPermissionState.denied;

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
          'Location access',
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
            child: isDenied ? _buildDeniedView(context, provider) : _buildPermissionRequestView(context, provider),
          ),
          const PagasaDisclaimerFooter(),
        ],
      ),
    );
  }

  // Normal request screen (Screen 2 from user images)
  Widget _buildPermissionRequestView(BuildContext context, AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryTeal,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'The right area. The right alert.',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use your location to center the map and find nearby flood risk.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),

        // Choice 1: While using the app
        _buildAccessOptionCard(
          title: 'While using the app',
          description: 'Find your position when Floop is open. Saved places can still receive alerts.',
        ),

        const SizedBox(height: 12),

        // Choice 2: Always
        _buildAccessOptionCard(
          title: 'Always',
          description: 'Background location helps Floop alert you as you travel, even when the app is closed.',
        ),

        const SizedBox(height: 16),

        // Info box: You stay in control
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.mintAccent.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
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
                      'You stay in control',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Location is used for area-based estimates. Change access anytime in Android Settings.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Button: While using the app
        ElevatedButton(
          onPressed: () {
            provider.setPermissionState(LocationPermissionState.whileUsingApp);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission set to "While using the app"'),
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
            'While using the app',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 12),

        // Button: Always
        OutlinedButton(
          onPressed: () {
            provider.setPermissionState(LocationPermissionState.always);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission set to "Always"'),
                backgroundColor: AppColors.primaryTeal,
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.surfaceBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Always',
            style: TextStyle(
              color: AppColors.primaryTeal,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Button: Not now · use saved places
        OutlinedButton(
          onPressed: () {
            provider.setPermissionState(LocationPermissionState.denied);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Switched to simulated Permission Denied mode for demo'),
                backgroundColor: Colors.orange,
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.surfaceBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Not now · use saved places',
            style: TextStyle(
              color: AppColors.primaryTeal,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Denied screen (Screen 3 of 4th image set)
  Widget _buildDeniedView(BuildContext context, AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.mintAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              color: AppColors.primaryTeal,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Location access is off',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Floop can\'t center the map on you or follow your area as you travel. You can still check saved places and search the map.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // Turn it on card
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
                'Turn it on in Android Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text('1. Open Permissions for Floop.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              SizedBox(height: 4),
              Text('2. Select Location.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              SizedBox(height: 4),
              Text('3. Choose While using the app or Always.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () {
            provider.setPermissionState(LocationPermissionState.always);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Simulated opening Android Settings & granted permission.'),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.settings, size: 18),
              SizedBox(width: 8),
              Text(
                'Open Android Settings',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.surfaceBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Continue with saved places',
            style: TextStyle(
              color: AppColors.primaryTeal,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),
        const Center(
          child: Text(
            'You decide what to share. Background access is optional.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessOptionCard({required String title, required String description}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
