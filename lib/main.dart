import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/app_theme.dart';
import 'core/app_constants.dart';
import 'providers/antrian_provider.dart';
import 'widgets/header_bar.dart';
import 'widgets/input_form_section.dart';
import 'widgets/preview_struk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for desktop SQLite
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Indonesian locale
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AntrianProvider()..initialize(),
      child: Consumer<AntrianProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: AppConstants.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AntreanPage(),
          );
        },
      ),
    );
  }
}

class AntreanPage extends StatelessWidget {
  const AntreanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          const HeaderBar(),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Two-column layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        // Desktop: side by side
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Input Form
                            Expanded(
                              flex: 3,
                              child: const InputFormSection(),
                            ),
                            const SizedBox(width: 24),
                            // Right: Preview
                            Expanded(
                              flex: 2,
                              child: const PreviewStruk(),
                            ),
                          ],
                        );
                      } else {
                        // Mobile: stacked
                        return Column(
                          children: const [
                            InputFormSection(),
                            SizedBox(height: 24),
                            PreviewStruk(),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  // Footer
                  Text(
                    '© ${DateTime.now().year} Satker Queue Management System ${AppConstants.appVersion}. Developed for Windows & Linux Desktop.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
