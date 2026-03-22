import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'score_logic.dart';
import 'rule_sheet.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

void showSettingsSheet(
  BuildContext context,
  AppTheme theme,
  ScoreController controller,
  bool isDarkMode,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: theme.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.textColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),

            _buildSettingsGroup("MATCH SETTINGS", theme, [
              _buildSettingTile(
                theme: theme,
                icon: Icons.format_list_numbered_rounded,
                title: "Match Format",
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.matchType,
                    dropdownColor: theme.cardColor,
                    icon: Icon(
                      Icons.unfold_more_rounded,
                      size: 18,
                      color: theme.subTextColor,
                    ),
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [1, 3, 5]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text("$e Sets"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.setMatchType(val);
                        setModalState(() {});
                      }
                    },
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSettingsGroup("PRIVACY", theme, [
              _buildSettingTile(
                theme: theme,
                icon: Icons.photo_library_rounded,
                title: "Photo Library",
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _handlePhotoPermissionAction(context, theme),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Manage",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.lightBlueAccent
                              : Colors.blueAccent,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.subTextColor.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              _buildSettingTile(
                theme: theme,
                icon: Icons.privacy_tip_rounded,
                title: "Privacy Policy",
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showPrivacyPolicy(context, theme),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isDarkMode
                        ? Colors.lightBlueAccent
                        : Colors.blueAccent,
                    size: 20,
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSettingsGroup("ABOUT", theme, [
              _buildSettingTile(
                theme: theme,
                icon: Icons.info_outline_rounded,
                title: "Version",
                trailing: Text(
                  "1.0.0",
                  style: TextStyle(color: theme.subTextColor, fontSize: 14),
                ),
              ),
              _buildSettingTile(
                theme: theme,
                icon: Icons.copyright_rounded,
                title: "Developer",
                trailing: Text(
                  "Vannik - Liu",
                  style: TextStyle(color: theme.subTextColor, fontSize: 14),
                ),
              ),
              _buildSettingTile(
                theme: theme,
                icon: Icons.description_rounded,
                title: "Rules",
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => showRulesDetail(context, theme),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "BWF Standard",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.lightBlueAccent
                              : Colors.blueAccent,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.subTextColor.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 32),

            Text(
              "© 2026 PRO BADMINTON TRACKER",
              style: TextStyle(
                color: theme.subTextColor.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: theme.itemGray,
                borderRadius: BorderRadius.circular(16),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Done",
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

Future<void> _handlePhotoPermissionAction(
  BuildContext context,
  AppTheme theme,
) async {
  if (!context.mounted) return;

  final hasAccess = await Gal.hasAccess();

  if (hasAccess) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Access already granted",
            style: TextStyle(color: theme.bgColor),
          ),
          backgroundColor: theme.textColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
    return;
  }

  final granted = await Gal.requestAccess();

  if (!context.mounted) return;

  if (granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Permission granted!",
          style: TextStyle(color: theme.bgColor),
        ),
        backgroundColor: theme.textColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Photo Access", style: TextStyle(color: theme.textColor)),
        content: Text(
          "We need your permission to save the scorecards to your gallery.",
          style: TextStyle(color: theme.subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Later", style: TextStyle(color: theme.subTextColor)),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: Text(
              "Settings",
              style: TextStyle(
                color: theme.isDark
                    ? Colors.lightBlueAccent
                    : Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showPrivacyPolicy(BuildContext context, AppTheme theme) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => Scaffold(
        backgroundColor: theme.bgColor,
        appBar: AppBar(
          backgroundColor: theme.cardColor,
          elevation: 0,
          title: Text(
            "Privacy",
            style: TextStyle(color: theme.textColor, fontSize: 18),
          ),
          iconTheme: IconThemeData(color: theme.textColor),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Text(
            '''
PRIVACY POLICY

1. DATA COLLECTION
This app is a local-first tool. We do NOT collect, store, or share any personal information.

2. PERMISSIONS
• Photo Library: Only used to save your generated match scorecards.
• Storage: Used locally to process temporary share files.

3. SECURITY
All match data stays on your device. No data is uploaded to any cloud server.
''',
            style: TextStyle(
              color: theme.textColor.withOpacity(0.9),
              height: 1.8,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildSettingsGroup(
  String label,
  AppTheme theme,
  List<Widget> children,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8, top: 12),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: theme.subTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: theme.cardShadow,
        ),
        child: Column(
          children: children.asMap().entries.map((entry) {
            int idx = entry.key;
            Widget child = entry.value;
            return Column(
              children: [
                child,
                if (idx < children.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Divider(
                      height: 1,
                      thickness: 0.5,
                      color: theme.hintColor,
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildSettingTile({
  required AppTheme theme,
  required IconData icon,
  required String title,
  required Widget trailing,
}) {
  return Container(
    constraints: const BoxConstraints(minHeight: 56),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.itemGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: theme.textColor.withOpacity(0.8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.textColor,
            ),
          ),
        ),
        trailing,
      ],
    ),
  );
}
