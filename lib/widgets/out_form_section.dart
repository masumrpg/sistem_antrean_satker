import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_constants.dart';
import '../core/app_theme.dart';
import '../providers/antrian_provider.dart';

class OutFormSection extends StatefulWidget {
  const OutFormSection({super.key});

  @override
  State<OutFormSection> createState() => _OutFormSectionState();
}

class _OutFormSectionState extends State<OutFormSection> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _fdController = TextEditingController();
  String _selectedSubSatker = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _fdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_fdController.text.isEmpty ||
        _namaController.text.isEmpty ||
        _selectedSubSatker.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data (No FD, Nama, Satker)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<AntrianProvider>();
    final fdNumber = int.tryParse(_fdController.text) ?? 0;

    final success = await provider.processOut(
      fdNumber,
      _namaController.text,
      _selectedSubSatker,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        _showSuccessDialog(fdNumber);
        _resetForm();
      } else {
        _showErrorDialog();
      }
    }
  }

  void _resetForm() {
    _namaController.clear();
    _fdController.clear();
    setState(() => _selectedSubSatker = '');
  }

  void _showSuccessDialog(int fdNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Berhasil'),
          ],
        ),
        content: Text(
            'Antrean FD ${fdNumber.toString().padLeft(3, '0')} berhasil diproses KELUAR.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Gagal'),
          ],
        ),
        content: const Text(
            'Data tidak ditemukan atau sudah KELUAR.\nPastikan Nomor FD, Nama (Pengunjung), dan Satker sesuai dengan data MASUK.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.outbox_rounded,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENGAMBILAN BERKAS (OUT)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masukkan data untuk memproses pengambilan',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Nomor FD Input
          Text(
            'NOMOR FD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _fdController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: AppTheme.inputDecoration(
              hint: 'Contoh: 1',
              isDark: isDark,
              prefixIcon: Icons.confirmation_number_rounded,
            ).copyWith(
              suffixText: 'FD',
              suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Nama Pengambil Input
          Text(
            'DITERIMA OLEH (NAMA)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _namaController,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: AppTheme.inputDecoration(
              hint: 'Nama penerima berkas',
              isDark: isDark,
              prefixIcon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 24),

          // Satker Selector
          Text(
            'DARI SATKER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: AppConstants.subSatkerList.length,
            itemBuilder: (context, index) {
              final sub = AppConstants.subSatkerList[index];
              final isSelected = _selectedSubSatker == sub.name;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedSubSatker = sub.name),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : (isDark
                                ? Colors.white24
                                : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sub.icon,
                          size: 20,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? Colors.white70
                                  : AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            sub.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white
                                      : AppTheme.textPrimary),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded),
                        SizedBox(width: 8),
                        Text(
                          'PROSES KELUAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
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
