import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'app_theme.dart';
import 'score_logic.dart';
import 'export_service.dart' hide debugPrint;
import 'score_card.dart';
import 'history_drawer.dart';
import 'export_template.dart';
import 'interval_banner.dart';
import 'mode_switcher.dart';
import 'control_icon.dart';
import 'top_bar.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  bool _isDarkMode = true;
  bool _showVictoryOverlay = false;

  AppTheme get theme => AppTheme(_isDarkMode);
  Color get setIndicatorColor => theme.setIndicatorColor;

  late final ScoreController _controller;
  bool _isDialogShowing = false;
  final GlobalKey _boundaryKey = GlobalKey();
  final ValueNotifier<Uint8List?> _exportBytesNotifier = ValueNotifier(null);

  final Color iosBlue = const Color(0xFF0A84FF);
  final Color iosRed = const Color(0xFFFF453A);
  final Color iosGray = const Color(0xFF1C1C1E);
  final Color iosAmber = const Color(0xFFFFD60A);

  @override
  void initState() {
    super.initState();
    _controller = ScoreController()..addListener(_onScoreChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScoreChanged);
    _controller.dispose();
    _exportBytesNotifier.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
    HapticFeedback.mediumImpact();
  }

  void _onScoreChanged() {
    if (!mounted) return;

    setState(() {});

    if (_controller.isMatchFinished &&
        !_isDialogShowing &&
        !_showVictoryOverlay) {
      _isDialogShowing = true;
      HapticFeedback.vibrate();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showVictoryOverlay = true;
          });
        }
      });
    }
  }

  Future<void> _exportAsImage() async {
    HapticFeedback.mediumImpact();
    _exportBytesNotifier.value = null;
    _showExportPreview();
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final RenderRepaintBoundary? boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData != null && mounted) {
        _exportBytesNotifier.value = byteData.buffer.asUint8List();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _showExportPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ValueListenableBuilder<Uint8List?>(
        valueListenable: _exportBytesNotifier,
        builder: (context, bytes, child) {
          bool isReady = bytes != null;
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.8,
            decoration: BoxDecoration(
              color: theme.bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.hintColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "SHARE SCORECARD",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: theme.subTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: isReady
                      ? Center(
                          child: InteractiveViewer(
                            child: Image.memory(bytes, fit: BoxFit.contain),
                          ),
                        )
                      : const Center(
                          child: CupertinoActivityIndicator(radius: 15),
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildExportBtn(
                        Icons.ios_share_rounded,
                        "SHARE",
                        iosBlue,
                        isReady ? () => ExportService.shareImage(bytes) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildExportBtn(
                        Icons.file_download_rounded,
                        "SAVE",
                        theme.itemGray,
                        isReady
                            ? () async {
                                bool ok = await ExportService.saveToGallery(
                                  bytes,
                                );
                                if (ok && mounted) Navigator.pop(ctx);
                              }
                            : null,
                        tColor: theme.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportBtn(
    IconData icon,
    String label,
    Color col,
    VoidCallback? tap, {
    Color tColor = Colors.white,
  }) {
    return ElevatedButton.icon(
      onPressed: tap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: tap == null ? Colors.grey : col,
        foregroundColor: tColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _editName(bool isA) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppTheme theme = AppTheme(isDark);
    final Color themeColor = isA ? iosBlue : iosRed;

    List<String> currentNames = isA
        ? _controller.playersA
        : _controller.playersB;
    List<TextEditingController> controllers = currentNames
        .map((name) => TextEditingController(text: name))
        .toList();

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          primaryColor: iosBlue,
        ),
        child: CupertinoAlertDialog(
          title: Text(
            "Edit ${isA ? 'Team A' : 'Team B'}",
            style: TextStyle(
              color: theme.textColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                controllers.length,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CupertinoTextField(
                    controller: controllers[index],
                    autofocus: true,
                    placeholder: "Player ${index + 1}",
                    placeholderStyle: TextStyle(
                      color: theme.subTextColor.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    style: TextStyle(color: theme.textColor, fontSize: 16),
                    cursorColor: themeColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  for (int i = 0; i < controllers.length; i++) {
                    _controller.updatePlayerName(
                      isA,
                      i,
                      controllers[i].text.trim(),
                    );
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(bool isAll) {
    HapticFeedback.heavyImpact();
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
          primaryColor: iosBlue,
        ),
        child: CupertinoAlertDialog(
          title: Text(
            isAll ? "Reset Match?" : "Reset Current Set?",
            style: TextStyle(color: theme.textColor),
          ),
          content: Text(
            isAll
                ? "This will clear all history."
                : "This will reset current score.",
            style: TextStyle(color: theme.subTextColor),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.textColor.withOpacity(0.6)),
              ),
              onPressed: () => Navigator.pop(ctx),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                setState(() {
                  isAll
                      ? _controller.resetAll()
                      : _controller.resetCurrentSet();
                });
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text(
                        isAll ? "Match Reset" : "Set Reset",
                        style: TextStyle(
                          color: _isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    backgroundColor: theme.textColor,
                    behavior: SnackBarBehavior.floating,
                    elevation: 0,
                    duration: const Duration(milliseconds: 1500),
                    width: 140,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.bgColor,
      resizeToAvoidBottomInset: false,
      endDrawerEnableOpenDragGesture: false,
      drawerScrimColor: Colors.transparent,
      endDrawer: HistoryDrawer(
        controller: _controller,
        iosGray: iosGray,
        iosBlue: iosBlue,
        iosRed: iosRed,
        iosAmber: iosAmber,
        theme: theme,
      ),
      body: Stack(
        children: [
          Positioned(
            left: -2000,
            child: RepaintBoundary(
              key: _boundaryKey,
              child: IosExportTemplate(controller: _controller),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TopBar(
                    controller: _controller,
                    theme: theme,
                    isDarkMode: _isDarkMode,
                    onToggleTheme: _toggleTheme,
                    setIndicatorColor: setIndicatorColor,
                  ),
                  IntervalBanner(controller: _controller, amberColor: iosAmber),
                  ModeSwitcher(
                    controller: _controller,
                    theme: theme,
                    isDarkMode: _isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ScoreCard(
                            isA: true,
                            controller: _controller,
                            color: iosBlue,
                            onNameTap: () => _editName(true),
                            theme: theme,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "V S",
                            style: TextStyle(
                              color: Colors.black12,
                              fontSize: 10,
                              letterSpacing: 8,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ScoreCard(
                            isA: false,
                            controller: _controller,
                            color: iosRed,
                            onNameTap: () => _editName(false),
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildBottomControls(),
                ],
              ),
            ),
          ),
          _buildVictoryOverlay(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ControlIcon(
            icon: Icons.undo,
            label: "UNDO",
            onTap: _controller.undo,
            enabled: _controller.canUndo,
            theme: theme,
          ),
          ControlIcon(
            icon: Icons.ios_share,
            label: "EXPORT",
            onTap: _exportAsImage,
            enabled: _controller.history.isNotEmpty,
            theme: theme,
          ),
          ControlIcon(
            icon: Icons.refresh,
            label: "RESET",
            onTap: () => _confirmReset(false),
            onLongPress: () => _confirmReset(true),
            enabled: true,
            theme: theme,
          ),
          _controller.isMatchFinished
              ? ControlIcon(
                  icon: Icons.play_circle_fill,
                  label: "NEW MATCH",
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _controller.resetAll();
                      _showVictoryOverlay = false;
                      _isDialogShowing = false;
                    });
                  },
                  enabled: true,
                  color: iosAmber,
                  theme: theme,
                )
              : ControlIcon(
                  icon: Icons.swap_vert,
                  label: "SWAP",
                  onTap: _controller.toggleServing,
                  enabled: true,
                  theme: theme,
                ),
        ],
      ),
    );
  }

  Widget _buildVictoryOverlay() {
    if (!_showVictoryOverlay) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _showVictoryOverlay = false;
                  _isDialogShowing = false;
                });
              },
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 5 * value,
                  sigmaY: 5 * value,
                ),
                child: Container(color: Colors.black.withOpacity(0.2 * value)),
              ),
            ),

            Center(
              child: Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0, 1),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? const Color(0xFF2C2C2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(28),
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
                        Icon(
                          Icons.emoji_events_rounded,
                          color: iosAmber,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "MATCH FINISHED",
                          style: TextStyle(
                            color: iosAmber,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${_controller.displayNameA}\nVS\n${_controller.displayNameB}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "SET SCORE: ${_controller.setsA} - ${_controller.setsB}",
                          style: TextStyle(
                            color: theme.subTextColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: _overlayButton(
                                "Export",
                                theme.itemGray,
                                theme.textColor,
                                () {
                                  setState(() {
                                    _showVictoryOverlay = false;
                                    _isDialogShowing = false;
                                  });
                                  _exportAsImage();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _overlayButton(
                                "New Match",
                                iosBlue,
                                Colors.white,
                                () {
                                  setState(() {
                                    _controller.resetAll();
                                    _showVictoryOverlay = false;
                                    _isDialogShowing = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _overlayButton(
    String label,
    Color bg,
    Color textCol,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: textCol, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
