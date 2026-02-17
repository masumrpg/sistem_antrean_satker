import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_constants.dart';
import '../core/app_theme.dart';
import '../models/antrian_model.dart';
import '../providers/antrian_provider.dart';

class OutFormSection extends StatefulWidget {
  const OutFormSection({super.key});

  @override
  State<OutFormSection> createState() => _OutFormSectionState();
}

class _OutFormSectionState extends State<OutFormSection> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _fdController = TextEditingController();
  final TextEditingController _spmController = TextEditingController();
  String _selectedSubSatker = '';
  bool _isLoading = false;
  Antrian? _foundAntrian;
  bool _isSearching = false;

  @override
  void dispose() {
    _namaController.dispose();
    _fdController.dispose();
    _spmController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    if (_fdController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masukkan Nomor FD')));
      return;
    }

    setState(() {
      _isSearching = true;
      _foundAntrian = null;
    });

    final provider = context.read<AntrianProvider>();
    final fdNumber = int.tryParse(_fdController.text) ?? 0;
    final result = await provider.findAntrianByFD(
      fdNumber,
    );

    setState(() {
      _isSearching = false;
      _foundAntrian = result;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data tidak ditemukan atau sudah diambil'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_foundAntrian == null) return;

    if (_namaController.text.isEmpty ||
        _selectedSubSatker.isEmpty ||
        _spmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi Nama Pengambil, Satker, dan No SPM'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<AntrianProvider>();
    final result = await provider.processOut(
      _foundAntrian!.nomorFD,
      _namaController.text,
      _selectedSubSatker,
      _spmController.text,
      date: _foundAntrian!.createdAt,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result != null) {
        _showSuccessDialog(result);
        _resetForm();
      } else {
        _showErrorDialog();
      }
    }
  }

  void _resetForm() {
    _namaController.clear();
    _fdController.clear();
    _spmController.clear();
    setState(() {
      _selectedSubSatker = '';
      _foundAntrian = null;
    });
  }

  void _showSuccessDialog(Antrian antrian) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Berhasil Diambil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antrean FD ${antrian.nomorFD.toString().padLeft(3, '0')} telah diperbarui.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Nomor FD',
                    antrian.nomorFD.toString().padLeft(3, '0'),
                  ),
                  const Divider(height: 16),
                  _buildInfoRow('Nama Pengunjung', antrian.nama),
                  const Divider(height: 16),
                  _buildInfoRow('Satker Tujuan', antrian.subSatker),
                  const Divider(height: 16),
                  _buildInfoRow('Diambil Oleh', antrian.takerName ?? '-'),
                  const Divider(height: 16),
                  _buildInfoRow('Satker Pengambil', antrian.takerSatker ?? '-'),
                  const Divider(height: 16),
                  _buildInfoRow('Nomor SPM', antrian.noSpm ?? '-'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
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
          'Data tidak ditemukan atau sudah KELUAR.\nPastikan Nomor FD, Nama, dan Satker sesuai.',
        ),
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
                      'PENGAMBILAN BERKAS (KELUAR)',
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

          // Tanggal Penitipan Removed as per requirements
          const SizedBox(height: 24),

          // Nomor FD Input & Search
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enabled: _foundAntrian == null,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration:
                      AppTheme.inputDecoration(
                        hint: 'Contoh: 1',
                        isDark: isDark,
                        prefixIcon: Icons.confirmation_number_rounded,
                      ).copyWith(
                        suffixText: 'FD',
                        suffixStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              if (_foundAntrian == null)
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _handleSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('CARI DATA'),
                  ),
                )
              else
                IconButton(
                  onPressed: () => setState(() => _foundAntrian = null),
                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                  tooltip: 'Ubah Nomor FD',
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (_foundAntrian != null) ...[
            // Found Record Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DATA PENITIPAN DITEMUKAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Nama Penitip', _foundAntrian!.nama),
                  const SizedBox(height: 8),
                  _buildInfoRow('Satker Tujuan', _foundAntrian!.subSatker),
                  const SizedBox(height: 8),
                  _buildInfoRow('Judul', _foundAntrian!.judul ?? '-'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Nominal',
                    'Rp ${_foundAntrian!.nominal ?? '-'}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Waktu Titip',
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                      'id_ID',
                    ).format(_foundAntrian!.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nama Pengambil Input
            Text(
              'DIAMBIL OLEH (NAMA)',
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
                hint: 'Siapa yang mengambil berkas?',
                isDark: isDark,
                prefixIcon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(height: 24),

            // Nomor SPM Input
            Text(
              'NOMOR SPM',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _spmController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: AppTheme.inputDecoration(
                hint: 'Masukkan Nomor SPM',
                isDark: isDark,
                prefixIcon: Icons.receipt_long_rounded,
              ),
            ),
            const SizedBox(height: 24),

            // Satker Selector
            Text(
              'DARI SATKER PENGAMBIL',
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
                            'PROSES PENGAMBILAN',
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
        ],
      ),
    );
  }
}
