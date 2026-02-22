import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../core/app_theme.dart';
import '../core/app_constants.dart';
import '../providers/antrian_provider.dart';

import '../pages/history_page.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AntrianProvider>();
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryDark,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // App icon
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                AppConstants.appSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Date & Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateFormat.format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                timeFormat.format(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Tooltip(
            message: 'Riwayat Antrean',
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              mouseCursor: SystemMouseCursors.click,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Export Button
          Tooltip(
            message: 'Ekspor Data (Backup)',
            child: InkWell(
              onTap: () => _handleExport(context),
              borderRadius: BorderRadius.circular(20),
              mouseCursor: SystemMouseCursors.click,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Import Button
          Tooltip(
            message: 'Impor Data (Restore)',
            child: InkWell(
              onTap: () => _handleImport(context),
              borderRadius: BorderRadius.circular(20),
              mouseCursor: SystemMouseCursors.click,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Dark mode toggle
          Tooltip(
            message: provider.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            child: InkWell(
              onTap: () => provider.toggleDarkMode(),
              borderRadius: BorderRadius.circular(20),
              mouseCursor: SystemMouseCursors.click,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  provider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final String? directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Pilih Folder Simpan Backup',
    );

    if (directoryPath != null) {
      final fileName =
          'backup_etiket_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db';
      final fullPath = p.join(directoryPath, fileName);

      if (context.mounted) {
        try {
          await context.read<AntrianProvider>().exportData(fullPath);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Berhasil diekspor ke: $fileName'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal ekspor: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Impor Database?'),
        content: const Text(
          'Tindakan ini akan mengganti seluruh data saat ini dengan data dari file yang dipilih.\n\nPASTIKAN ANDA SUDAH MELAKUKAN BACKUP TERLEBIH DAHULU.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('SAYA MENGERTI, LANJUTKAN'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      if (!context.mounted) return;
      try {
        await context.read<AntrianProvider>().importData(
          result.files.single.path!,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database berhasil diimpor'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengimpor data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
