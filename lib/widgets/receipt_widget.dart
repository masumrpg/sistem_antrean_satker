import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/antrian_model.dart';
import '../providers/antrian_provider.dart';
import '../core/app_theme.dart';

class ReceiptWidget extends StatelessWidget {
  final Antrian antrian;
  final bool isPreview;

  const ReceiptWidget({
    super.key,
    required this.antrian,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    final returnDate = antrian.createdAt.add(Duration(days: antrian.durasi));
    final returnDateStr = '${dateFormat.format(returnDate)} (${antrian.durasi} hari)';

    // Determine colors based on preview mode or theme context
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isPreview
        ? Colors.black // Always perform like paper on preview
        : (isDark ? Colors.white : Colors.black);
    final backgroundColor = isPreview
        ? Colors.white
        : (isDark ? AppTheme.cardDark : Colors.white);

    return Container(
      width: 300, // Approximate thermal printer width
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isPreview ? 0 : 12),
        boxShadow: isPreview
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
        border: isPreview ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'E-Ticket',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Pelayanan Terpadu',
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'TANDA TERIMA BERKAS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Dashed Divider simulation
          CustomPaint(
            painter: DashedLinePainter(color: textColor.withValues(alpha: 0.5)),
            size: const Size(double.infinity, 1),
          ),
          const SizedBox(height: 12),

          // Queue Number
          Text(
            'NOMOR ANTREAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: textColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              antrian.nomorFD.toString().padLeft(3, '0'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          CustomPaint(
            painter: DashedLinePainter(color: textColor.withValues(alpha: 0.5)),
            size: const Size(double.infinity, 1),
          ),
          const SizedBox(height: 12),

          // Details List
          _buildRow('No. FD', antrian.nomorFD.toString().padLeft(3, '0'), textColor),
          _buildRow('Nama', antrian.nama, textColor),
          _buildRow('Satker', antrian.subSatker, textColor),
          if (antrian.judul != null && antrian.judul!.isNotEmpty)
            _buildRow('Judul', antrian.judul!, textColor),
          if (antrian.nominal != null && antrian.nominal!.isNotEmpty)
            _buildRow(
              'Nominal',
              'Rp ${AntrianProvider.formatNominalValue(antrian.nominal)}',
              textColor,
            ),
          _buildRow('Durasi', '${antrian.durasi} Hari', textColor),
          _buildRow(
            'Waktu Masuk',
            '${dateFormat.format(antrian.createdAt)} ${timeFormat.format(antrian.createdAt)}',
            textColor,
          ),
          const SizedBox(height: 8),
          Divider(color: textColor.withValues(alpha: 0.2), height: 16),
          const SizedBox(height: 8),

          _buildRow('Tanggal Kembali', returnDateStr, textColor),

          if (antrian.status == Antrian.statusOut) ...[
            const SizedBox(height: 12),
            CustomPaint(
              painter: DashedLinePainter(
                color: textColor.withValues(alpha: 0.5),
              ),
              size: const Size(double.infinity, 1),
            ),
            const SizedBox(height: 12),
            Text(
              'INFORMASI PENGAMBILAN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildRow('Diambil Oleh', antrian.takerName ?? '-', textColor),
            _buildRow('Dari Satker', antrian.takerSatker ?? '-', textColor),
            _buildRow('No. SPM', antrian.noSpm ?? '-', textColor),
            _buildRow(
              'Waktu Ambil',
              antrian.outAt != null
                  ? '${dateFormat.format(antrian.outAt!)} ${timeFormat.format(antrian.outAt!)}'
                  : '-',
              textColor,
            ),
          ],

          const SizedBox(height: 24),
          CustomPaint(
            painter: DashedLinePainter(color: textColor.withValues(alpha: 0.5)),
            size: const Size(double.infinity, 1),
          ),
          const SizedBox(height: 12),

          // Footer
          Text(
            'Harap bawa struk ini saat pengambilan berkas.',
            style: TextStyle(
              fontSize: 9,
              color: textColor.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '© ${DateTime.now().year} E-Tiket',
            style: TextStyle(
              fontSize: 8,
              color: textColor.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 11, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
