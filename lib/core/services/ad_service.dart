import 'package:flutter/foundation.dart';

/// AdSense integration for web.
/// Ads are injected via web/index.html using Google AdSense script.
/// This service provides ad slot configuration.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // TODO: Replace with your actual AdSense publisher ID
  static const String publisherId = 'ca-pub-XXXXXXXXXXXXXXXX';

  Future<void> initialize() async {
    debugPrint('AdService: Web ads are handled via AdSense in index.html');
  }
}
