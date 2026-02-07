import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/ads/models/ad_item.dart';
import '../../../core/ads/ad_service.dart';
import '../../../core/ads/ad_config.dart';

/// 模拟插页广告组件
class MockInterstitialAd extends StatefulWidget {
  final AdItem? ad;
  final VoidCallback? onClose;
  final VoidCallback? onTap;

  const MockInterstitialAd({
    super.key,
    this.ad,
    this.onClose,
    this.onTap,
  });

  /// 显示插页广告
  static Future<void> show(BuildContext context, {
    AdItem? ad,
    VoidCallback? onClose,
    VoidCallback? onTap,
  }) async {
    final adItem = ad ?? AdService.instance.getInterstitialAd();
    if (adItem == null) {
      onClose?.call();
      return;
    }

    AdService.instance.trackImpression(adItem);

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => MockInterstitialAd(
        ad: adItem,
        onClose: () {
          Navigator.of(context).pop();
          onClose?.call();
        },
        onTap: onTap,
      ),
    );
  }

  @override
  State<MockInterstitialAd> createState() => _MockInterstitialAdState();
}

class _MockInterstitialAdState extends State<MockInterstitialAd> {
  late int _countdown;
  Timer? _timer;
  bool _canClose = false;

  // 插页广告配色
  static const List<List<Color>> _adColors = [
    [Color(0xFF1A1A2E), Color(0xFF16213E)],
    [Color(0xFF2C3E50), Color(0xFF3498DB)],
    [Color(0xFF0F2027), Color(0xFF2C5364)],
  ];

  @override
  void initState() {
    super.initState();
    _countdown = AdConfig.instance.interstitialCloseDelay;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _canClose = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adItem = widget.ad!;
    final colorIndex = adItem.id.hashCode.abs() % _adColors.length;
    final colors = _adColors[colorIndex];

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 广告内容
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // 图标
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          adItem.advertiser,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 关闭按钮
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _canClose ? widget.onClose : null,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _canClose
                              ? const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : Text(
                                  '$_countdown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  // 广告标签
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        '广告',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 文字内容
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    adItem.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    adItem.description ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  // 行动按钮
                  GestureDetector(
                    onTap: () {
                      AdService.instance.trackClick(adItem);
                      widget.onTap?.call();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colors),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        adItem.actionText ?? '查看详情',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 跳过按钮
                  GestureDetector(
                    onTap: _canClose ? widget.onClose : null,
                    child: Text(
                      _canClose ? '关闭' : '$_countdown 秒后可关闭',
                      style: TextStyle(
                        fontSize: 12,
                        color: _canClose
                            ? const Color(0xFF666666)
                            : const Color(0xFFBBBBBB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
