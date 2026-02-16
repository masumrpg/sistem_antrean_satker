import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/antrian_model.dart';
import '../providers/antrian_provider.dart';
import 'receipt_widget.dart';

class PreviewStruk extends StatelessWidget {
  const PreviewStruk({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AntrianProvider>();
    final isDark = provider.isDarkMode;

    // Create a temporary Antrian object for preview
    final previewData = Antrian(
      id: 0, // Dummy ID
      nama: provider.nama.isEmpty ? 'Nama Pengunjung' : provider.nama,
      subSatker: provider.selectedSubSatker.isEmpty
          ? 'Satker Tujuan'
          : provider.selectedSubSatker,
      nomorFD: provider.nomorFD,
      durasi: provider.durasi,
      createdAt: DateTime.now(),
      status: 'IN',
    );

    return Card(
      margin: EdgeInsets.zero,
      color: isDark ? AppTheme.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'PREVIEW STRUK',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: provider.isPrinterConnected
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        provider.isPrinterConnected
                            ? Icons.print_rounded
                            : Icons.print_disabled_rounded,
                        size: 12,
                        color: provider.isPrinterConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.isPrinterConnected
                            ? 'Printer Siap'
                            : 'Printer Off',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: provider.isPrinterConnected
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Receipt Preview Area
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ReceiptWidget(antrian: previewData, isPreview: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
