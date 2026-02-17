import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/app_theme.dart';
import 'core/app_constants.dart';
import 'providers/antrian_provider.dart';
import 'pages/splash_screen.dart';
import 'widgets/header_bar.dart';

import 'widgets/input_form_section.dart';
import 'widgets/preview_struk.dart';
import 'widgets/out_form_section.dart';

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
            home: const SplashScreen(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            // Header
            const HeaderBar(),
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
              ),
              child: TabBar(
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryBlue,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'MASUK (IN)'),
                  Tab(text: 'KELUAR (OUT)'),
                ],
              ),
            ),
            // Content
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: MASUK (IN)
                  _buildInTab(),
                  // Tab 2: KELUAR (OUT)
                  _buildOutTab(isDark),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
              child: Text(
                '© ${DateTime.now().year} SIASAT - Sistem Antrean Satker ${AppConstants.appVersion}. Developed for Windows & Linux Desktop.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop: side by side
            return const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: InputFormSection()),
                SizedBox(width: 24),
                Expanded(flex: 2, child: PreviewStruk()),
              ],
            );
          } else {
            // Mobile: stacked
            return const Column(
              children: [
                InputFormSection(),
                SizedBox(height: 24),
                PreviewStruk(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildOutTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop: Centered Form
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    child: const OutFormSection(),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            );
          } else {
            // Mobile: Full width
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: const OutFormSection(),
            );
          }
        },
      ),
    );
  }
}
