import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/antrian_provider.dart';

class PreviewStruk extends StatelessWidget {
  const PreviewStruk({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AntrianProvider>();
    final isDark = provider.isDarkMode;

    return Column(
      children: [
        // Preview Card
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
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
                  ],
                ),
                const SizedBox(height: 20),
                // Struk preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Dashed top border
                      _dashedLine(),
                      const SizedBox(height: 16),
                      const Text(
                        'MOCK STRUK',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _dashedLine(),
                      const SizedBox(height: 16),
                      // Detail rows
                      _buildDetailRow(
                        'No. FD:',
                        provider.nomorFDFormatted,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Nama:',
                        provider.nama.isNotEmpty
                            ? provider.nama
                            : '-',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Tujuan:',
                        provider.selectedSubSatker.isNotEmpty
                            ? provider.selectedSubSatker
                            : '-',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Durasi:',
                        '${provider.durasi} Hari',
                      ),
                      const SizedBox(height: 20),
                      // QR-like icon placeholder
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          size: 50,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Terima kasih atas kunjungan Anda',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _dashedLine(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Printer status
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Printer:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  provider.isPrinterConnected
                      ? 'Terhubung'
                      : 'Tidak Terhubung',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: provider.isPrinterConnected
                        ? AppTheme.successGreen
                        : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: provider.isPrinterConnected
                        ? AppTheme.successGreen
                        : Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: (provider.isPrinterConnected
                                ? AppTheme.successGreen
                                : Colors.red)
                            .withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _dashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 5.0;
        final dashCount = (constraints.maxWidth / (dashWidth * 2)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth * 2,
              child: Center(
                child: Container(
                  width: dashWidth,
                  height: 1,
                  color: const Color(0xFFD1D5DB),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
