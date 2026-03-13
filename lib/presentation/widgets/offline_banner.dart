import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.accentColor.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: AppTheme.accentColor, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode — showing cached rates',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
