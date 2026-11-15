import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/providers/reader_settings_provider.dart';
import 'package:nu_news/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);
    final readerSettings = ref.watch(readerSettingsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.slate900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Kelola tema aplikasi, preferensi membaca, dan data',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.slate400 : AppTheme.slate500,
          ),
        ),
        const SizedBox(height: 18),

        // 1. Tampilan & Tema
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tampilan & Tema',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.slate900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ThemeChoiceButton(
                      icon: Icons.wb_sunny_rounded,
                      label: 'Mode Terang',
                      isSelected: currentTheme == ThemeMode.light,
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .setTheme(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeChoiceButton(
                      icon: Icons.nightlight_round,
                      label: 'Mode Gelap',
                      isSelected: currentTheme == ThemeMode.dark,
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .setTheme(ThemeMode.dark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Status Pembaca
        _SettingsCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.text_fields_rounded,
                        size: 17,
                        color: AppTheme.slate500,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status Pembaca (Customize View)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppTheme.slate900,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(readerSettingsProvider.notifier).reset();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pengaturan pembaca dikembalikan ke default',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: AppTheme.rose500,
                    ),
                    label: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.rose500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: 'FONT',
                      value:
                          '${readerSettings.fontStyle.name} (${readerSettings.fontSize.round()}px)',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoTile(
                      label: 'TEMA BACAAN',
                      value: readerSettings.themeColor.name,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Language & Info
        _SettingsCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.public_rounded,
                        size: 16,
                        color: AppTheme.slate400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bahasa Aplikasi',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.slate200 : AppTheme.slate700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Bahasa Indonesia (ID)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.slate900,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: isDark ? AppTheme.slate800 : AppTheme.slate100,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: AppTheme.slate400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Versi Aplikasi',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.slate200 : AppTheme.slate700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'NuNews v2.4 (Flutter)',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.slate800 : AppTheme.slate200,
        ),
      ),
      child: child,
    );
  }
}

class _ThemeChoiceButton extends StatelessWidget {
  const _ThemeChoiceButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isSelected
        ? (isDark ? Colors.white : AppTheme.slate900)
        : (isDark ? AppTheme.slate800.withAlpha(180) : AppTheme.slate50);
    final fgColor = isSelected
        ? (isDark ? AppTheme.slate900 : Colors.white)
        : (isDark ? AppTheme.slate200 : AppTheme.slate700);
    final borderColor = isSelected
        ? (isDark ? Colors.white : AppTheme.slate900)
        : (isDark ? AppTheme.slate700 : AppTheme.slate200);

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        hoverColor: isDark
            ? (isSelected
                ? Colors.white.withAlpha(215)
                : AppTheme.slate800.withAlpha(102))
            : (isSelected ? AppTheme.slate800 : AppTheme.slate100),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fgColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800.withAlpha(150) : AppTheme.slate50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.slate400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.slate900,
            ),
          ),
        ],
      ),
    );
  }
}
