import 'package:flutter/material.dart';

/// Placeholder banner ad widget for web.
/// In production, ads are shown via AdSense injected in index.html.
/// This widget shows a styled placeholder that can be replaced
/// with HtmlElementView for actual AdSense integration.
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          'مساحة إعلانية',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
