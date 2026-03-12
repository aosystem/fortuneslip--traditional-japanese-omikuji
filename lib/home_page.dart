import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fortuneslip/l10n/app_localizations.dart';
import 'package:fortuneslip/parse_locale_tag.dart';
import 'package:fortuneslip/settings_page.dart';
import 'package:fortuneslip/ad_manager.dart';
import 'package:fortuneslip/ad_banner_widget.dart';
import 'package:fortuneslip/audio_play.dart';
import 'package:fortuneslip/text_to_speech.dart';
import 'package:fortuneslip/theme_color.dart';
import 'package:fortuneslip/fortune_item.dart';
import 'package:fortuneslip/model.dart';
import 'package:fortuneslip/theme_mode_number.dart';
import 'package:fortuneslip/loading_screen.dart';
import 'package:fortuneslip/main.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> with TickerProviderStateMixin {
  late AdManager _adManager;
  late AudioPlay _audioPlay;
  late Random _random;
  late ThemeColor _themeColor;
  bool _isReady = false;
  bool _isFirst = true;
  //
  late List<FortuneItem> _fortuneItems;
  static const int _frameCount = 120;
  static const List<_TextSpec> _textSpecs = [
    _TextSpec(frame: 84, x: 547, y: 440),
    _TextSpec(frame: 85, x: 549, y: 444),
    _TextSpec(frame: 86, x: 550, y: 450),
    _TextSpec(frame: 87, x: 550, y: 454),
    _TextSpec(frame: 88, x: 552, y: 459),
    _TextSpec(frame: 89, x: 554, y: 464),
    _TextSpec(frame: 90, x: 555, y: 469),
    _TextSpec(frame: 91, x: 556, y: 474),
    _TextSpec(frame: 92, x: 558, y: 479),
    _TextSpec(frame: 93, x: 560, y: 484),
    _TextSpec(frame: 94, x: 562, y: 489),
    _TextSpec(frame: 95, x: 563, y: 495),
    _TextSpec(frame: 96, x: 565, y: 500),
    _TextSpec(frame: 97, x: 567, y: 505),
    _TextSpec(frame: 98, x: 569, y: 511),
    _TextSpec(frame: 99, x: 571, y: 516),
    _TextSpec(frame: 100, x: 573, y: 522),
    _TextSpec(frame: 101, x: 575, y: 530),
    _TextSpec(frame: 102, x: 578, y: 539),
    _TextSpec(frame: 103, x: 580, y: 550),
    _TextSpec(frame: 104, x: 583, y: 563),
    _TextSpec(frame: 105, x: 587, y: 576),
    _TextSpec(frame: 106, x: 590, y: 592),
    _TextSpec(frame: 107, x: 594, y: 608),
    _TextSpec(frame: 108, x: 599, y: 626),
    _TextSpec(frame: 109, x: 604, y: 645),
    _TextSpec(frame: 110, x: 608, y: 665),
    _TextSpec(frame: 111, x: 614, y: 687),
    _TextSpec(frame: 112, x: 619, y: 708),
    _TextSpec(frame: 113, x: 625, y: 730),
    _TextSpec(frame: 114, x: 630, y: 751),
    _TextSpec(frame: 115, x: 636, y: 772),
    _TextSpec(frame: 116, x: 641, y: 792),
    _TextSpec(frame: 117, x: 646, y: 808),
    _TextSpec(frame: 118, x: 651, y: 822),
    _TextSpec(frame: 119, x: 654, y: 832),
  ];
  static const int _countdownFramesPerDigit = 30;
  static const Duration _countdownFrameInterval = Duration(milliseconds: 30);
  static const Duration _ticketFrameDuration = Duration(milliseconds: 40);

  Timer? _animationTimer;
  Timer? _countdownTimer;
  int _currentFrame = 0;
  int? _countdown;
  String? _countdownAsset;
  double _countdownScale = 1.1;
  double _countdownOpacity = 0;
  int _countdownFrames = 0;
  int _countdownValue = 0;
  List<ui.Image> _decodedFrames = [];
  Future<void>? _frameLoadFuture;
  bool _framesReady = false;
  Future<void>? _countdownPrecacheFuture;
  FortuneItem? _activeFortune;
  bool _isAnimating = false;

  bool get _isBusy => _isAnimating || _countdown != null;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    _adManager = AdManager();
    _audioPlay = AudioPlay();
    _random = Random();
    await TextToSpeech.applyPreferences(Model.ttsVoiceId,Model.ttsVolume);
    _fortuneItems = [
      FortuneItem(rawName: Model.fortune1, ratio: Model.ratio1),
      FortuneItem(rawName: Model.fortune2, ratio: Model.ratio2),
      FortuneItem(rawName: Model.fortune3, ratio: Model.ratio3),
      FortuneItem(rawName: Model.fortune4, ratio: Model.ratio4),
      FortuneItem(rawName: Model.fortune5, ratio: Model.ratio5),
      FortuneItem(rawName: Model.fortune6, ratio: Model.ratio6),
    ];
    _frameLoadFuture = _loadAnimationFrames();
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _countdownPrecacheFuture ??= _precacheCountdownAssets(context);
  }

  @override
  void dispose() {
    _adManager.dispose();
    _animationTimer?.cancel();
    _countdownTimer?.cancel();
    TextToSpeech.stop();
    for (final image in _decodedFrames) {
      image.dispose();
    }
    _decodedFrames = [];
    super.dispose();
  }

  void _handleTap() {
    if (_isBusy) {
      return;
    }
    final selected = _selectFortune();
    if (selected == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.empty)),
      );
      return;
    }
    setState(() {
      _activeFortune = selected;
      _currentFrame = 0;
      _isAnimating = false;
    });

    final int countdownTarget = Model.countdownTime;
    if (countdownTarget <= 0) {
      setState(() {
        _countdown = null;
        _countdownAsset = null;
        _countdownOpacity = 0;
      });
      unawaited(_startAnimation());
      return;
    }

    setState(() {
      _audioPlay.play();
      _countdownValue = countdownTarget;
      _countdown = _countdownValue;
      _countdownFrames = _countdownFramesPerDigit;
      _countdownAsset = _countdownAssetFor(_countdownValue);
      _countdownScale = 1.1;
      _countdownOpacity = 0;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(_countdownFrameInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdownFrames -= 1;
        if (_countdownFrames <= 0) {
          _countdownValue -= 1;
          if (_countdownValue <= 0) {
            _countdown = null;
            _countdownAsset = null;
            _countdownOpacity = 0;
            timer.cancel();
            unawaited(_startAnimation());
            return;
          }
          _countdown = _countdownValue;
          _countdownFrames = _countdownFramesPerDigit;
          _countdownAsset = _countdownAssetFor(_countdownValue);
        }

        final frame = _countdownFrames.toDouble();
        _countdownScale = 1 + 0.1 * (frame / _countdownFramesPerDigit);
        if (frame >= 20) {
          _countdownOpacity = (_countdownFramesPerDigit - frame) / 10;
        } else if (frame <= 5) {
          _countdownOpacity = frame / 5;
        } else {
          _countdownOpacity = 1;
        }
        if (_countdownOpacity < 0) {
          _countdownOpacity = 0;
        } else if (_countdownOpacity > 1) {
          _countdownOpacity = 1;
        }
      });
    });
  }

  Future<void> _precacheCountdownAssets(BuildContext context) async {
    final ctx = context;
    final futures = <Future<void>>[];
    for (var i = 1; i <= 9; i++) {
      futures.add(precacheImage(AssetImage(_countdownAssetFor(i)), ctx));
    }
    futures.add(
      precacheImage(const AssetImage('assets/image/number_null.webp'), ctx),
    );
    try {
      await Future.wait(futures);
    } catch (_) {
    }
  }

  Future<void> _loadAnimationFrames() async {
    final frames = <ui.Image>[];
    try {
      for (var i = 0; i < _frameCount; i++) {
        final data = await rootBundle.load(_frameAsset(i));
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        try {
          final frame = await codec.getNextFrame();
          frames.add(frame.image);
        } finally {
          codec.dispose();
        }
      }
      if (!mounted) {
        for (final image in frames) {
          image.dispose();
        }
        return;
      }
      setState(() {
        _decodedFrames = frames;
        _framesReady = true;
      });
    } catch (_) {
      for (final image in frames) {
        image.dispose();
      }
      if (mounted) {
        setState(() {
          _decodedFrames = [];
          _framesReady = true;
        });
      } else {
        _framesReady = true;
      }
    }
  }

  Future<void> _ensureFramesReady() async {
    if (_framesReady) {
      return;
    }
    final future = _frameLoadFuture;
    if (future != null) {
      try {
        await future;
      } catch (_) {
      }
    }
  }

  Future<void> _startAnimation() async {
    _animationTimer?.cancel();
    await _ensureFramesReady();
    if (!mounted) {
      return;
    }
    setState(() {
      _isAnimating = true;
      _currentFrame = 0;
    });
    _animationTimer = Timer.periodic(_ticketFrameDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_currentFrame >= _frameCount - 1) {
          timer.cancel();
          _isAnimating = false;
          _currentFrame = _frameCount - 1;
          _speakResult();
        } else {
          _currentFrame += 1;
        }
      });
    });
  }

  FortuneItem? _selectFortune() {
    final candidates = _fortuneItems
        .where((item) => item.ratio > 0 && item.display.isNotEmpty)
        .toList();
    final total = candidates.fold<int>(0, (value, item) => value + item.ratio);
    if (total == 0) {
      return null;
    }
    var remain = _random.nextInt(total);
    for (final item in candidates) {
      remain -= item.ratio;
      if (remain < 0) {
        return item;
      }
    }
    return candidates.isNotEmpty ? candidates.last : null;
  }

  Future<void> _speakResult() async {
    if (!Model.ttsEnabled || _activeFortune == null) {
      return;
    }
    final text = _activeFortune!.reading;
    if (text.isEmpty) {
      return;
    }
    await TextToSpeech.speak(text);
  }

  Future<void> _onOpenSetting() async {
    if (_isBusy) {
      return;
    }
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingPage()),
    );
    if (!mounted) {
      return;
    }
    if (updated == true) {
      final mainState = context.findAncestorStateOfType<MainAppState>();
      if (mainState != null) {
        mainState
          ..themeMode = ThemeModeNumber.numberToThemeMode(Model.themeNumber)
          ..locale = parseLocaleTag(Model.languageCode)
          ..setState(() {});
      }
      await TextToSpeech.applyPreferences(Model.ttsVoiceId,Model.ttsVolume);
      _fortuneItems = [
        FortuneItem(rawName: Model.fortune1, ratio: Model.ratio1),
        FortuneItem(rawName: Model.fortune2, ratio: Model.ratio2),
        FortuneItem(rawName: Model.fortune3, ratio: Model.ratio3),
        FortuneItem(rawName: Model.fortune4, ratio: Model.ratio4),
        FortuneItem(rawName: Model.fortune5, ratio: Model.ratio5),
        FortuneItem(rawName: Model.fortune6, ratio: Model.ratio6),
      ];
      _isFirst = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady == false) {
      return const LoadingScreen();
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(context: context);
    }
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _themeColor.mainBackColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Opacity(
          opacity: _isBusy ? 0.1 : 1,
          child: Text(
            l.tapToDraw,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _themeColor.mainForeColor,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Opacity(
            opacity: _isBusy ? 0.1 : 1,
            child: IconButton(
              icon: const Icon(Icons.settings),
              color: _themeColor.mainForeColor,
              tooltip: l.setting,
              onPressed: _onOpenSetting,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Container(
          color: _themeColor.mainBackColor,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: _buildDrawingArea()),
                      if (_countdownAsset != null) _buildCountdownOverlay(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AdBannerWidget(adManager: _adManager),
    );
  }

  Widget _buildDrawingArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final boxSize = min(width, height);
        final marginLeft = (width - boxSize) / 2;
        final marginTop = (height - boxSize) / 2;
        final textLayout = _layoutForFrame(
          _currentFrame,
          boxSize,
          marginLeft,
          marginTop,
        );
        final imageAsset = _frameAsset(_currentFrame);
        final ui.Image? frameImage = _decodedFrames.isEmpty
            ? null
            : _decodedFrames[_currentFrame.clamp(0, _decodedFrames.length - 1)];
        return Stack(
          children: [
            Positioned(
              left: marginLeft,
              top: marginTop,
              width: boxSize,
              height: boxSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: frameImage != null
                      ? CustomPaint(
                          painter: _FramePainter(frameImage),
                          child: const SizedBox.expand(),
                        )
                      : Image.asset(
                          imageAsset,
                          fit: BoxFit.contain,
                          key: ValueKey<int>(_currentFrame),
                          gaplessPlayback: true,
                        ),
                ),
              ),
            ),
            if (textLayout != null && _activeFortune != null)
              Positioned(
                left: textLayout.offset.dx,
                top: textLayout.offset.dy,
                child: Opacity(
                  opacity: _currentFrame >= 84 ? 1 : 0,
                  child: Text(
                    _activeFortune!.display,
                    style: TextStyle(
                      fontSize: textLayout.fontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCountdownOverlay() {
    final asset = _countdownAsset;
    if (asset == null) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Opacity(
            opacity: _countdownOpacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _countdownScale,
              child: Image.asset(asset),
            ),
          ),
        ),
      ),
    );
  }

  _TextLayout? _layoutForFrame(
    int frame,
    double boxSize,
    double marginLeft,
    double marginTop,
  ) {
    if (frame < 84) {
      return null;
    }
    final spec = _textSpecs.firstWhere(
      (element) => element.frame == frame,
      orElse: () => const _TextSpec(frame: -1, x: 0, y: 0),
    );
    if (spec.frame == -1) {
      return null;
    }
    final boxPixel = boxSize / 900.0;
    final dx = marginLeft + boxPixel * spec.x - boxPixel * ((frame - 84) + 36);
    final dy =
        marginTop + boxPixel * spec.y - boxPixel * ((frame - 84) * 1.3 + 24);
    final fontSize = ((frame - 84) / (119 - 84)) * 14 + 4;
    return _TextLayout(offset: Offset(dx, dy), fontSize: fontSize);
  }

  String _frameAsset(int frame) {
    final clamped = frame.clamp(0, 119) + 1;
    final padded = clamped.toString().padLeft(3, '0');
    return 'assets/image/fortune/omikuji$padded.jpg';
  }

  String _countdownAssetFor(int value) {
    var clamped = value;
    if (clamped <= 0) {
      return 'assets/image/number_null.webp';
    }
    if (clamped > 9) {
      clamped = 9;
    }
    return 'assets/image/number${clamped.toString()}.webp';
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    if (imageWidth == 0 ||
        imageHeight == 0 ||
        size.width == 0 ||
        size.height == 0) {
      return;
    }
    final imageAspect = imageWidth / imageHeight;
    final canvasAspect = size.width / size.height;
    Rect dst;
    if (imageAspect > canvasAspect) {
      final drawHeight = size.width / imageAspect;
      final dy = (size.height - drawHeight) / 2.0;
      dst = Rect.fromLTWH(0, dy, size.width, drawHeight);
    } else {
      final drawWidth = size.height * imageAspect;
      final dx = (size.width - drawWidth) / 2.0;
      dst = Rect.fromLTWH(dx, 0, drawWidth, size.height);
    }
    final src = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) {
    return oldDelegate.image != image;
  }
}

class _TextSpec {
  const _TextSpec({required this.frame, required this.x, required this.y});

  final int frame;
  final double x;
  final double y;
}

class _TextLayout {
  const _TextLayout({required this.offset, required this.fontSize});

  final Offset offset;
  final double fontSize;
}
