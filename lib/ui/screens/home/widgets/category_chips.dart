import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/constants/news_category.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/providers/news_provider.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedSlug =
        ref.watch(newsProvider.select((s) => s.selectedCategory));

    return SizedBox(
      height: 40,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: kNewsCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat = kNewsCategories[index];
            final isSelected = selectedSlug == cat.slug;

            final bgColor = isSelected
                ? (isDark ? Colors.white : AppTheme.slate900)
                : (isDark
                    ? AppTheme.slate800.withAlpha(190)
                    : Colors.white);
            final textColor = isSelected
                ? (isDark ? AppTheme.slate900 : Colors.white)
                : (isDark ? AppTheme.slate200 : AppTheme.slate700);
            final borderColor = isSelected
                ? (isDark ? Colors.white : AppTheme.slate900)
                : (isDark ? AppTheme.slate700 : AppTheme.slate200);

            return Material(
              color: bgColor,
              shape: StadiumBorder(
                side: BorderSide(color: borderColor),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                hoverColor: isDark
                    ? (isSelected
                        ? Colors.white.withAlpha(215)
                        : AppTheme.slate800.withAlpha(110))
                    : (isSelected
                        ? AppTheme.slate800
                        : AppTheme.slate50),
                onTap: () {
                  ref.read(newsProvider.notifier).setCategory(cat.slug);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_rounded, size: 14, color: textColor),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
