import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBannerAdUnitId;
    }
    // TODO: Replace with your actual AdMob banner ad unit ID
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob initialized successfully');
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
    }
  }

  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
