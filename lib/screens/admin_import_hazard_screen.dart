import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import 'admin_review_import_screen.dart';

class AdminImportHazardScreen extends StatefulWidget {
  const AdminImportHazardScreen({super.key});

  @override
  State<AdminImportHazardScreen> createState() => _AdminImportHazardScreenState();
}

class _AdminImportHazardScreenState extends State<AdminImportHazardScreen> {
  final TextEditingController _sourceController = TextEditingController(
    text: 'Floop sample hazard dataset v1.1',
  );
  String? _selectedFileName;

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValidateEnabled = _selectedFileName != null;

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
          'Import hazard data',
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
                const Text(
                  'Update the hazard layer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Upload long-term flood susceptibility boundaries. This does not replace live predictions.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 16),

                // Dashed Drag & Drop Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryTeal.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primaryTeal),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFileName ?? 'Choose a hazard file',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'GeoJSON · WGS84 · up to 10 MB',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFileName = 'marikina_sample.geojson';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected "marikina_sample.geojson" (124 KB)'),
                              backgroundColor: AppColors.primaryTeal,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.surfaceBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          _selectedFileName == null ? 'Browse files' : 'Change file',
                          style: const TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Source / dataset name
                const Text(
                  'Source / dataset name',
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
                    hintText: 'Enter the source and version',
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

                const SizedBox(height: 16),

                // Required fields info card
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
                      const Text(
                        'Required fields',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Zone name, boundary geometry and hazard level: Low, Medium or High.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Text(
                            'Download sample GeoJSON ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.open_in_new, size: 14, color: AppColors.primaryTeal),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Mint info: Review before publishing
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
                              'Review before publishing',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'We\'ll validate your file first. Existing zones stay unchanged until you confirm.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Validate file button
                ElevatedButton(
                  onPressed: isValidateEnabled
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminReviewImportScreen(
                                fileName: _selectedFileName!,
                                datasetSource: _sourceController.text.trim(),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    disabledBackgroundColor: const Color(0xFFD6DFDC),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF6B7280),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Validate file',
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
}
