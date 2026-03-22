import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'score_logic.dart';
import 'app_theme.dart';
import 'game_state.dart';

// ✅ 核心优化：将抽屉改为 StatefulWidget，支持预加载和延迟渲染
class HistoryDrawer extends StatefulWidget {
  final ScoreController controller;
  final Color iosGray, iosBlue, iosRed, iosAmber;
  final AppTheme theme;

  const HistoryDrawer({
    super.key,
    required this.controller,
    required this.iosGray,
    required this.iosBlue,
    required this.iosRed,
    required this.iosAmber,
    required this.theme,
  });

  @override
  State<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isContentLoaded = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _slideController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _isContentLoaded = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.controller.groupedHistory.reversed.toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.85;

    return SlideTransition(
      position: _slideAnimation,
      child: ClipRect(
        child: Container(
          width: drawerWidth,
          padding: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: widget.theme.bgColor.withOpacity(0.92),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20.0,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
              tileMode: TileMode.clamp,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 4),
                    itemCount: groups.isEmpty ? 1 : groups.length,
                    itemBuilder: (context, index) {
                      if (groups.isEmpty) {
                        return SizedBox(
                          height: screenWidth * 0.6,
                          child: _buildEmptyState(),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 12,
                          top: index == 0 ? 12 : 0,
                          bottom: index == groups.length - 1 ? 40 : 12,
                        ),
                        child: _buildSetCard(groups[index], context),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 16,
        right: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.iosAmber, widget.iosAmber.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TIMELINE",
                  style: TextStyle(
                    fontSize: 17,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                    color: widget.theme.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Long press to revert",
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.theme.subTextColor.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                onPressed: () => _showClearAllConfirm(context),
                icon: Icon(
                  Icons.delete_sweep_rounded,
                  color: widget.iosRed.withOpacity(0.8),
                  size: 16,
                ),
                tooltip: "Clear All",
              ),
              const SizedBox(width: 2),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  _slideController.reverse().then((_) {
                    Navigator.pop(context);
                  });
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: widget.theme.subTextColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetCard(SetGroup group, BuildContext context) {
    bool isCurrentSet = !group.isFinished;
    final points = group.points;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCurrentSet
            ? widget.theme.textColor.withOpacity(0.06)
            : widget.theme.textColor.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrentSet
              ? widget.iosAmber.withOpacity(0.4)
              : widget.theme.textColor.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: _CustomExpansionTile(
          animationDuration: const Duration(milliseconds: 200),
          initiallyExpanded: isCurrentSet,
          title: Row(
            children: [
              _buildSetBadge(group),
              const SizedBox(width: 12),
              _buildScoreSummary(group),
            ],
          ),
          children: [
            Divider(color: widget.theme.textColor.withOpacity(0.05), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: [
                  ...points.reversed.map((p) => _buildPointItem(p, context)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointItem(ScoreState p, BuildContext context) {
    if (widget.controller.history.isEmpty) return const SizedBox.shrink();

    final bool aWon = p.dA > 0;
    final bool bWon = p.dB > 0;

    return Dismissible(
      key: ValueKey('point_${p.id}_${p.sA}_${p.sB}'),
      direction: DismissDirection.endToStart,
      resizeDuration: const Duration(milliseconds: 150),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: widget.iosRed.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Color(0xFFD32F2F),
          size: 22,
        ),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.heavyImpact();
        return true;
      },
      onDismissed: (direction) {
        widget.controller.deleteHistoryPoint(p.id);
      },
      child: InkWell(
        onLongPress: () {
          HapticFeedback.heavyImpact();
          _showRevertConfirm(context, p);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildPointIndicator(aWon, widget.iosBlue),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: (aWon || bWon)
                        ? widget.theme.textColor.withOpacity(0.05)
                        : widget.theme.textColor.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: p.isAServing ? 1.0 : 0.0,
                        child: _buildServeDot(widget.iosBlue),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 70,
                        child: Text(
                          "${p.sA.toString().padLeft(2, '0')} - ${p.sB.toString().padLeft(2, '0')}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: widget.theme.textColor.withOpacity(0.9),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Opacity(
                        opacity: !p.isAServing ? 1.0 : 0.0,
                        child: _buildServeDot(widget.iosRed),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildPointIndicator(bWon, widget.iosRed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointIndicator(bool won, Color color) {
    return SizedBox(
      width: 20,
      child: won
          ? Text(
              "+1",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildServeDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4.0,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildSetBadge(SetGroup group) {
    bool isCurrent = !group.isFinished;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? widget.iosAmber : Colors.transparent,
        border: Border.all(
          color: isCurrent
              ? widget.iosAmber
              : widget.theme.subTextColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "SET ${group.setNumber}",
        style: TextStyle(
          color: isCurrent ? Colors.black : widget.theme.subTextColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildScoreSummary(SetGroup group) {
    return SizedBox(
      width: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildScoreDigit(
            group.setScoreA.toString(),
            widget.iosBlue,
            group.setScoreA > group.setScoreB,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ":",
              style: TextStyle(
                color: widget.theme.subTextColor.withOpacity(0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildScoreDigit(
            group.setScoreB.toString(),
            widget.iosRed,
            group.setScoreB > group.setScoreA,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDigit(String score, Color color, bool isWinner) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, maxWidth: 36),
      child: Text(
        score,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isWinner ? FontWeight.w900 : FontWeight.w500,
          fontFamily: 'monospace',
          color: isWinner ? color : color.withOpacity(0.5),
        ),
      ),
    );
  }

  void _showRevertConfirm(BuildContext context, ScoreState p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.theme.bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Revert Point?",
          style: TextStyle(color: widget.theme.textColor),
        ),
        content: Text(
          "Jump back to ${p.sA} - ${p.sB}?",
          style: TextStyle(color: widget.theme.subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: TextStyle(color: widget.theme.subTextColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.iosBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              widget.controller.jumpToHistory(
                widget.controller.history.indexWhere((h) => h.id == p.id),
              );
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 56,
            color: widget.theme.subTextColor.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            "No points yet...",
            style: TextStyle(
              color: widget.theme.subTextColor.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.theme.bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Clear All?",
          style: TextStyle(color: widget.theme.textColor),
        ),
        content: Text(
          "This will delete all history.",
          style: TextStyle(color: widget.theme.subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: TextStyle(color: widget.theme.subTextColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.iosRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              widget.controller.resetAll();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              "Clear All",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Duration animationDuration;

  const _CustomExpansionTile({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<_CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<_CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..value = _isExpanded ? 1.0 : 0.0;

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _toggleExpansion,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: widget.title),
                RotationTransition(
                  turns: Tween<double>(
                    begin: 0,
                    end: 0.5,
                  ).animate(_expandAnimation),
                  child: const Icon(Icons.keyboard_arrow_down, size: 20),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axis: Axis.vertical,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.children,
            ),
          ),
        ),
      ],
    );
  }
}
