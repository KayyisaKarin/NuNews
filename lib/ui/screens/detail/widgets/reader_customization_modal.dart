import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/providers/reader_settings_provider.dart';

/// Modal bottom sheet "Customize your view" triggered from "Aa" button.
class ReaderCustomizationModal extends ConsumerWidget {
  const ReaderCustomizationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReaderCustomizationModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(readerSettingsProvider);
    final notifier = ref.read(readerSettingsProvider.notifier);

    const themeColors = [
      (
        id: ReaderThemeColor.white,
        label: 'Putih Terang',
        bg: Colors.white,
        border: Color(0xFFCBD5E1),
      ),
      (
        id: ReaderThemeColor.sepia,
        label: 'Kuning Pastel Hangat',
        bg: AppTheme.pastelYellowLightPill,
        border: Color(0xFFFDE047),
      ),
      (
        id: ReaderThemeColor.slate,
        label: 'Abu Slate',
        bg: Color(0xFF64748B),
        border: Color(0xFF475569),
      ),
      (
        id: ReaderThemeColor.oled,
        label: 'Hitam OLED',
        bg: Colors.black,
        border: Color(0xFF262626),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppTheme.slate800 : AppTheme.slate200,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).viewPadding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Customize your view',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.slate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sesuaikan preferensi membaca artikel Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.slate400 : AppTheme.slate500,
            ),
          ),
          const SizedBox(height: 22),

          // 1. Font Style
          Text(
            'Font Style',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.slate200 : AppTheme.slate700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.slate800 : AppTheme.slate100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FontOptionButton(
                    label: 'Sans',
                    isSerif: false,
                    isSelected: settings.fontStyle == ReaderFontStyle.sans,
                    onTap: () => notifier.setFontStyle(ReaderFontStyle.sans),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _FontOptionButton(
                    label: 'Serif',
                    isSerif: true,
                    isSelected: settings.fontStyle == ReaderFontStyle.serif,
                    onTap: () => notifier.setFontStyle(ReaderFontStyle.serif),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Font Size
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.slate200 : AppTheme.slate700,
                ),
              ),
              Text(
                '${settings.fontSize.round()}px',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                ),
              ),
              Expanded(
                child: Slider(
                  min: 13,
                  max: 22,
                  divisions: 9,
                  value: settings.fontSize,
                  activeColor: isDark ? Colors.white : AppTheme.slate900,
                  onChanged: notifier.setFontSize,
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Brightness
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brightness',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.slate200 : AppTheme.slate700,
                ),
              ),
              Text(
                '${(settings.brightness * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                size: 16,
                color: isDark ? AppTheme.slate400 : AppTheme.slate500,
              ),
              Expanded(
                child: Slider(
                  min: 0.5,
                  max: 1.0,
                  divisions: 10,
                  value: settings.brightness,
                  activeColor: isDark ? Colors.white : AppTheme.slate900,
                  onChanged: notifier.setBrightness,
                ),
              ),
              Icon(
                Icons.wb_sunny_rounded,
                size: 20,
                color: isDark ? Colors.white : AppTheme.slate900,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Theme Color Circles
          Text(
            'Theme Color',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.slate200 : AppTheme.slate700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: themeColors.map((option) {
              final selected = settings.themeColor == option.id;
              return GestureDetector(
                onTap: () => notifier.setThemeColor(option.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: option.bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppTheme.rose500 : option.border,
                      width: selected ? 2.5 : 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppTheme.rose500.withAlpha(65),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: AppTheme.rose500,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 5. Done button
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppTheme.slate900,
                foregroundColor: isDark ? AppTheme.slate900 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FontOptionButton extends StatelessWidget {
  const _FontOptionButton({
    required this.label,
    required this.isSerif,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSerif;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isSelected
          ? (isDark ? AppTheme.slate900 : Colors.white)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: isSerif ? 'serif' : null,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? AppTheme.rose500
                  : (isDark ? AppTheme.slate400 : AppTheme.slate700),
            ),
          ),
        ),
      ),
    );
  }
}
