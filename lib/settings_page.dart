import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:fortuneslip/l10n/app_localizations.dart';
import 'package:fortuneslip/ad_manager.dart';
import 'package:fortuneslip/ad_banner_widget.dart';
import 'package:fortuneslip/ad_ump_status.dart';
import 'package:fortuneslip/theme_color.dart';
import 'package:fortuneslip/text_to_speech.dart';
import 'package:fortuneslip/model.dart';
import 'package:fortuneslip/loading_screen.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late AdManager _adManager;
  late UmpConsentController _adUmp;
  AdUmpState _adUmpState = AdUmpState.initial;
  int _themeNumber = 0;
  String _languageCode = '';
  late ThemeColor _themeColor;
  final _inAppReview = InAppReview.instance;
  bool _isReady = false;
  bool _isFirst = true;
  //
  late List<TtsOption> _ttsVoices;
  bool _ttsEnabled = true;
  String _ttsVoiceId = '';
  double _ttsVolume = 1.0;
  //
  late List<TextEditingController> _fortuneControllers;
  late List<TextEditingController> _ratioControllers;
  late int _countdownTime;
  late double _soundVolume;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    _adManager = AdManager();
    _themeNumber = Model.themeNumber;
    _languageCode = Model.languageCode;
    //
    _adUmp = UmpConsentController();
    _refreshConsentInfo();
    //
    _fortuneControllers = List.generate(7, (_) => TextEditingController());
    _fortuneControllers[0].text = Model.fortune1;
    _fortuneControllers[1].text = Model.fortune2;
    _fortuneControllers[2].text = Model.fortune3;
    _fortuneControllers[3].text = Model.fortune4;
    _fortuneControllers[4].text = Model.fortune5;
    _fortuneControllers[5].text = Model.fortune6;
    _fortuneControllers[6].text = Model.fortune7;
    _ratioControllers = List.generate(7, (_) => TextEditingController());
    _ratioControllers[0].text = Model.ratio1.toString();
    _ratioControllers[1].text = Model.ratio2.toString();
    _ratioControllers[2].text = Model.ratio3.toString();
    _ratioControllers[3].text = Model.ratio4.toString();
    _ratioControllers[4].text = Model.ratio5.toString();
    _ratioControllers[5].text = Model.ratio6.toString();
    _ratioControllers[6].text = Model.ratio7.toString();
    _countdownTime = Model.countdownTime;
    _soundVolume = Model.soundVolume;
    _ttsEnabled = Model.ttsEnabled;
    _ttsVolume = Model.ttsVolume;
    _ttsVoiceId = Model.ttsVoiceId;
    //speech
    await TextToSpeech.getInstance();
    _ttsVoices = TextToSpeech.ttsVoices;
    TextToSpeech.setVolume(_ttsVolume);
    TextToSpeech.setTtsVoiceId(_ttsVoiceId);
    //
    setState(() {
      _isReady = true;
    });
  }

  Future<void> _refreshConsentInfo() async {
    _adUmpState = await _adUmp.updateConsentInfo(current: _adUmpState);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onTapPrivacyOptions() async {
    final err = await _adUmp.showPrivacyOptions();
    await _refreshConsentInfo();
    if (err != null && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.cmpErrorOpeningSettings} ${err.message}')),
      );
    }
  }

  @override
  void dispose() {
    _adManager.dispose();
    for (final controller in _fortuneControllers) {
      controller.dispose();
    }
    for (final controller in _ratioControllers) {
      controller.dispose();
    }
    TextToSpeech.stop();
    super.dispose();
  }

  Future<void> _onApply() async {
    await Model.setFortune1(_fortuneControllers[0].text);
    await Model.setFortune2(_fortuneControllers[1].text);
    await Model.setFortune3(_fortuneControllers[2].text);
    await Model.setFortune4(_fortuneControllers[3].text);
    await Model.setFortune5(_fortuneControllers[4].text);
    await Model.setFortune6(_fortuneControllers[5].text);
    await Model.setFortune7(_fortuneControllers[6].text);
    await Model.setRatio1(int.tryParse(_ratioControllers[0].text) ?? 0);
    await Model.setRatio2(int.tryParse(_ratioControllers[1].text) ?? 0);
    await Model.setRatio3(int.tryParse(_ratioControllers[2].text) ?? 0);
    await Model.setRatio4(int.tryParse(_ratioControllers[3].text) ?? 0);
    await Model.setRatio5(int.tryParse(_ratioControllers[4].text) ?? 0);
    await Model.setRatio6(int.tryParse(_ratioControllers[5].text) ?? 0);
    await Model.setRatio7(int.tryParse(_ratioControllers[6].text) ?? 0);
    await Model.setCountdownTime(_countdownTime);
    await Model.setSoundVolume(_soundVolume);
    await Model.setTtsEnabled(_ttsEnabled);
    await Model.setTtsVoiceId(_ttsVoiceId);
    await Model.setTtsVolume(_ttsVolume);
    await Model.setThemeNumber(_themeNumber);
    await Model.setLanguageCode(_languageCode);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const LoadingScreen();
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(themeNumber: _themeNumber, context: context);
    }
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _themeColor.backColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(l.setting),
        foregroundColor: _themeColor.appBarForegroundColor,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: _onApply,
              tooltip: l.apply,
              icon: const Icon(Icons.check),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 100),
            children: [
              _buildFortuneTable(l),
              _buildCountdown(l),
              _buildSpeech(l),
              _buildTheme(l),
              _buildLanguage(l),
              _buildReview(l),
              _buildCmp(l),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdBannerWidget(adManager: _adManager),
    );
  }

  Widget _buildFortuneTable(AppLocalizations l) {
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
                2: IntrinsicColumnWidth(),
                3: IntrinsicColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(l.fortune),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(l.ratio),
                    ),
                    const SizedBox(),
                  ],
                ),
                for (var i = 0; i < _fortuneControllers.length; i++)
                  TableRow(
                    children: [
                      Text('${i + 1}  '),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 4, bottom: 4),
                        child: TextField(
                          controller: _fortuneControllers[i],
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 0, bottom: 4),
                        child: SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _ratioControllers[i],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox.shrink(),
                    ]
                  )
              ]
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            child: Text(l.fortunesHint),
          )
        ]
      )
    );
  }

  Widget _buildCountdown(AppLocalizations l) {
    return Column(children:[
      Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                children: [
                  Text(l.countdownTime),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  Text(_countdownTime.toStringAsFixed(0)),
                  Expanded(
                    child: Slider(
                        value: _countdownTime.toDouble(),
                        min: 0,
                        max: 9,
                        divisions: 9,
                        label: _countdownTime.toString(),
                        onChanged: (double value) {
                          setState(() {
                            _countdownTime = value.toInt();
                          });
                        }
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
      Card(
        margin: const EdgeInsets.only(left: 0, top: 2, right: 0, bottom: 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  Text(l.soundVolume),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  Text(_soundVolume.toStringAsFixed(1)),
                  Expanded(
                    child: Slider(
                        value: _soundVolume.toDouble(),
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: _soundVolume.toString(),
                        onChanged: (double value) {
                          setState(() {
                            _soundVolume = value;
                          });
                        }
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      )
    ]);
  }

  Widget _buildSpeech(AppLocalizations l) {
    if (_ttsVoices.isEmpty) {
      return SizedBox.shrink();
    }
    final l = AppLocalizations.of(context)!;
    return Column(children:[
      Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.ttsEnabled,
                    ),
                  ),
                  Switch(
                    value: _ttsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _ttsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        )
      ),
      Card(
        margin: const EdgeInsets.only(left: 0, top: 2, right: 0, bottom: 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  Text(
                    l.ttsVolume,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  Text(_ttsVolume.toStringAsFixed(1)),
                  Expanded(
                    child: Slider(
                      value: _ttsVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: _ttsVolume.toStringAsFixed(1),
                      onChanged: _ttsEnabled
                          ? (double value) {
                        setState(() {
                          _ttsVolume = double.parse(
                            value.toStringAsFixed(1),
                          );
                        });
                      }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
      Card(
        margin: const EdgeInsets.only(left: 0, top: 2, right: 0, bottom: 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
              child: DropdownButtonFormField<String>(
                initialValue: () {
                  if (_ttsVoiceId.isNotEmpty && _ttsVoices.any((o) => o.id == _ttsVoiceId)) {
                    return _ttsVoiceId;
                  }
                  return _ttsVoices.first.id;
                }(),
                items: _ttsVoices
                    .map((o) => DropdownMenuItem<String>(value: o.id, child: Text(o.label)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) {
                    return;
                  }
                  setState(() => _ttsVoiceId = v);
                },
              ),
            ),
          ],
        )
      )
    ]);
  }

  Widget _buildTheme(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l.theme,
                style: t.bodyMedium,
              ),
            ),
            DropdownButton<int>(
              value: _themeNumber,
              items: [
                DropdownMenuItem(value: 0, child: Text(l.systemSetting)),
                DropdownMenuItem(value: 1, child: Text(l.lightTheme)),
                DropdownMenuItem(value: 2, child: Text(l.darkTheme)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _themeNumber = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguage(AppLocalizations l) {
    final Map<String,String> languageNames = {
      'af': 'af: Afrikaans',
      'ar': 'ar: العربية',
      'bg': 'bg: Български',
      'bn': 'bn: বাংলা',
      'bs': 'bs: Bosanski',
      'ca': 'ca: Català',
      'cs': 'cs: Čeština',
      'da': 'da: Dansk',
      'de': 'de: Deutsch',
      'el': 'el: Ελληνικά',
      'en': 'en: English',
      'es': 'es: Español',
      'et': 'et: Eesti',
      'fa': 'fa: فارسی',
      'fi': 'fi: Suomi',
      'fil': 'fil: Filipino',
      'fr': 'fr: Français',
      'gu': 'gu: ગુજરાતી',
      'he': 'he: עברית',
      'hi': 'hi: हिन्दी',
      'hr': 'hr: Hrvatski',
      'hu': 'hu: Magyar',
      'id': 'id: Bahasa Indonesia',
      'it': 'it: Italiano',
      'ja': 'ja: 日本語',
      'km': 'km: ខ្មែរ',
      'kn': 'kn: ಕನ್ನಡ',
      'ko': 'ko: 한국어',
      'lt': 'lt: Lietuvių',
      'lv': 'lv: Latviešu',
      'ml': 'ml: മലയാളം',
      'mr': 'mr: मराठी',
      'ms': 'ms: Bahasa Melayu',
      'my': 'my: မြန်မာ',
      'ne': 'ne: नेपाली',
      'nl': 'nl: Nederlands',
      'or': 'or: ଓଡ଼ିଆ',
      'pa': 'pa: ਪੰਜਾਬੀ',
      'pl': 'pl: Polski',
      'pt': 'pt: Português',
      'ro': 'ro: Română',
      'ru': 'ru: Русский',
      'si': 'si: සිංහල',
      'sk': 'sk: Slovenčina',
      'sr': 'sr: Српски',
      'sv': 'sv: Svenska',
      'sw': 'sw: Kiswahili',
      'ta': 'ta: தமிழ்',
      'te': 'te: తెలుగు',
      'th': 'th: ไทย',
      'tl': 'tl: Tagalog',
      'tr': 'tr: Türkçe',
      'uk': 'uk: Українська',
      'ur': 'ur: اردو',
      'uz': 'uz: Oʻzbekcha',
      'vi': 'vi: Tiếng Việt',
      'zh': 'zh: 中文',
      'zu': 'zu: isiZulu',
    };
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l.language,
                style: t.bodyMedium,
              ),
            ),
            DropdownButton<String?>(
              value: _languageCode,
              items: [
                DropdownMenuItem(value: '', child: Text('Default')),
                ...languageNames.entries.map((entry) => DropdownMenuItem<String?>(
                  value: entry.key,
                  child: Text(entry.value),
                )),
              ],
              onChanged: (String? value) {
                setState(() {
                  _languageCode = value ?? '';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.reviewApp, style: t.bodyMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.open_in_new, size: 16),
                  label: Text(l.reviewStore, style: t.bodySmall),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await _inAppReview.openStoreListing(
                      appStoreId: 'YOUR_APP_STORE_ID',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCmp(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    final showButton = _adUmpState.privacyStatus == PrivacyOptionsRequirementStatus.required;
    String statusLabel = l.cmpCheckingRegion;
    IconData statusIcon = Icons.help_outline;
    switch (_adUmpState.privacyStatus) {
      case PrivacyOptionsRequirementStatus.required:
        statusLabel = l.cmpRegionRequiresSettings;
        statusIcon = Icons.privacy_tip_outlined;
        break;
      case PrivacyOptionsRequirementStatus.notRequired:
        statusLabel = l.cmpRegionNoSettingsRequired;
        statusIcon = Icons.check_circle_outline;
        break;
      case PrivacyOptionsRequirementStatus.unknown:
        statusLabel = l.cmpRegionCheckFailed;
        statusIcon = Icons.error_outline;
        break;
    }
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.cmpSettingsTitle,
              style: t.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l.cmpConsentDescription,
              style: t.bodySmall,
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Chip(
                    avatar: Icon(statusIcon, size: 18),
                    label: Text(statusLabel),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l.cmpConsentStatusLabel} ${_adUmpState.consentStatus.localized(context)}',
                    style: t.bodySmall,
                  ),
                  if (showButton) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _adUmpState.isChecking
                          ? null
                          : _onTapPrivacyOptions,
                      icon: const Icon(Icons.settings),
                      label: Text(
                        _adUmpState.isChecking
                            ? l.cmpConsentStatusChecking
                            : l.cmpOpenConsentSettings,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _adUmpState.isChecking
                          ? null
                          : _refreshConsentInfo,
                      icon: const Icon(Icons.refresh),
                      label: Text(l.cmpRefreshStatus),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final message = l.cmpResetStatusDone;
                        await ConsentInformation.instance.reset();
                        await _refreshConsentInfo();
                        if (!mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: Text(l.cmpResetStatus),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
