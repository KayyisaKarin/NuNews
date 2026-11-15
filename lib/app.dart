import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/providers/theme_provider.dart';
import 'package:nu_news/ui/screens/main_shell/main_shell_screen.dart';

/// Root NuNews MaterialApp wired to Riverpod ThemeProvider.
class NuNewsApp extends ConsumerWidget {
  const NuNewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'NuNews',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainShellScreen(),
    );
  }
}
