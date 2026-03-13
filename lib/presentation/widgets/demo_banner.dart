import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryColor.withOpacity(0.15),
            AppTheme.primaryColor.withOpacity(0.10),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: const [
          Icon(Icons.science_rounded, color: AppTheme.secondaryColor, size: 15),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo mode — using sample rates. Add API key for live data.',
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
