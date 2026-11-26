import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'providers/app_provider.dart';
import 'screens/admin_reports_screen.dart';
import 'screens/admin_zones_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/flood_map_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/notification_shade_dialog.dart';
import 'services/firebase_service.dart';
import 'theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService().initialize();
  runApp(const FloopApp());
}

class FloopApp extends StatelessWidget {
  const FloopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Floop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryTeal,
            primary: AppColors.primaryTeal,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        home: const MainNavigationShell(),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _residentTabIndex = 0; // 0: Locations, 1: Map, 2: Alerts
  int _adminTabIndex = 0; // 0: Reports, 1: Zones

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAdmin = provider.isAdmin;

    return Scaffold(
      body: Stack(
        children: [
          // Current Tab Page strictly determined by RBAC
          isAdmin
              ? _buildAdminPage(_adminTabIndex)
              : _buildResidentPage(_residentTabIndex),

          // Floating Top-Right Role & Scenario Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            right: 12,
            child: _buildDevFloatingControls(context, provider),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: isAdmin ? _buildAdminNavItems(provider) : _buildResidentNavItems(provider),
          ),
        ),
      ),
    );
  }

  Widget _buildResidentPage(int index) {
    switch (index) {
      case 0:
        return LocationsScreen(
          onNavigateTab: (idx) {
            setState(() {
              _residentTabIndex = idx;
            });
          },
        );
      case 1:
        return const FloodMapScreen();
      case 2:
      default:
        return AlertsScreen(
          onNavigateTab: (idx) {
            setState(() {
              _residentTabIndex = idx;
            });
          },
        );
    }
  }

  Widget _buildAdminPage(int index) {
    switch (index) {
      case 0:
        return AdminReportsScreen(
          onSwitchToZones: () {
            setState(() {
              _adminTabIndex = 1;
            });
          },
        );
      case 1:
      default:
        return const AdminZonesScreen();
    }
  }

  List<Widget> _buildResidentNavItems(AppProvider provider) {
    return [
      _buildNavItem(
        index: 0,
        isSelected: _residentTabIndex == 0,
        icon: Icons.location_on_outlined,
        selectedIcon: Icons.location_on,
        label: 'Locations',
        onTap: () => setState(() => _residentTabIndex = 0),
      ),
      _buildNavItem(
        index: 1,
        isSelected: _residentTabIndex == 1,
        icon: Icons.map_outlined,
        selectedIcon: Icons.map,
        label: 'Map',
        onTap: () => setState(() => _residentTabIndex = 1),
      ),
      _buildNavItem(
        index: 2,
        isSelected: _residentTabIndex == 2,
        icon: Icons.notifications_none_outlined,
        selectedIcon: Icons.notifications,
        label: 'Alerts',
        onTap: () => setState(() => _residentTabIndex = 2),
      ),
    ];
  }

  List<Widget> _buildAdminNavItems(AppProvider provider) {
    return [
      _buildNavItem(
        index: 0,
        isSelected: _adminTabIndex == 0,
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        label: 'Reports',
        onTap: () => setState(() => _adminTabIndex = 0),
      ),
      _buildNavItem(
        index: 1,
        isSelected: _adminTabIndex == 1,
        icon: Icons.layers_outlined,
        selectedIcon: Icons.layers,
        label: 'Zones',
        onTap: () => setState(() => _adminTabIndex = 1),
      ),
    ];
  }

  Widget _buildNavItem({
    required int index,
    required bool isSelected,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.mintAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevFloatingControls(BuildContext context, AppProvider provider) {
    final user = provider.currentUser;

    return PopupMenuButton<String>(
      tooltip: 'RBAC & Scenario Controls',
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: provider.isAdmin ? AppColors.adminDarkBanner : AppColors.primaryTeal,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              provider.isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${user.role.displayName}: ${user.displayName.split(" ").first}',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
          ],
        ),
      ),
      onSelected: (val) {
        switch (val) {
          case 'switch_to_admin':
            provider.switchUserRole(UserRole.admin);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('RBAC Active: Switched to Administrator (Full Admin Access)'),
                backgroundColor: AppColors.adminDarkBanner,
              ),
            );
            break;
          case 'switch_to_resident':
            provider.switchUserRole(UserRole.resident);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('RBAC Active: Switched to Resident User (Restricted Admin Views)'),
                backgroundColor: AppColors.primaryTeal,
              ),
            );
            break;
          case 'auth_dialog':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AuthScreen(onAuthenticated: () => Navigator.of(context).pop())),
            );
            break;
          case 'toggle_offline':
            provider.setOffline(!provider.isOffline);
            break;
          case 'toggle_loading':
            provider.setLoading(!provider.isLoading);
            break;
          case 'empty_locations':
            provider.clearAllLocations();
            break;
          case 'empty_alerts':
            provider.clearAlertHistory();
            break;
          case 'empty_reports':
            provider.clearAdminQueue();
            break;
          case 'reset_demo':
            provider.restoreDemoLocations();
            provider.setOffline(false);
            provider.setLoading(false);
            break;
          case 'simulate_notification':
            showDialog(
              context: context,
              builder: (_) => NotificationShadeDialog(
                onNavigateTab: (idx) {
                  setState(() {
                    _residentTabIndex = idx;
                  });
                },
              ),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'auth_dialog',
          child: Row(
            children: const [
              Icon(Icons.login, size: 18, color: AppColors.primaryTeal),
              SizedBox(width: 8),
              Text('Switch User / Sign In'),
            ],
          ),
        ),
        PopupMenuItem(
          value: provider.isAdmin ? 'switch_to_resident' : 'switch_to_admin',
          child: Row(
            children: [
              Icon(
                provider.isAdmin ? Icons.person : Icons.admin_panel_settings,
                size: 18,
                color: AppColors.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(provider.isAdmin ? 'Switch to Resident (RBAC)' : 'Switch to Admin (RBAC)'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'simulate_notification',
          child: const Text('🔔 Simulate Push Notification'),
        ),
        PopupMenuItem(
          value: 'toggle_offline',
          child: Text(provider.isOffline ? 'Disable Offline Mode' : 'Simulate Offline Mode'),
        ),
        PopupMenuItem(
          value: 'toggle_loading',
          child: Text(provider.isLoading ? 'Stop Loading State' : 'Simulate Loading / Skeleton'),
        ),
        PopupMenuItem(
          value: 'empty_locations',
          child: const Text('Simulate Empty Saved Locations'),
        ),
        PopupMenuItem(
          value: 'empty_alerts',
          child: const Text('Simulate Empty Alert History'),
        ),
        PopupMenuItem(
          value: 'empty_reports',
          child: const Text('Simulate Admin Empty Queue'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'reset_demo',
          child: Text('↺ Reset all to default demo data', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
