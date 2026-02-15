import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../core/database_helper.dart';
import '../models/antrian_model.dart';
import '../providers/antrian_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Antrian> _allHistory = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper.instance;
    final records = _selectedDate == null
        ? await db.getAllAntrian()
        : await db.getAntrianByDate(_selectedDate!);

    if (mounted) {
      setState(() {
        _allHistory = records.map((e) => Antrian.fromMap(e)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2024),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadHistory();
    }
  }

  void _clearFilter() {
    setState(() => _selectedDate = null);
    _loadHistory();
  }

  void _showDetailDialog(Antrian antrian) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue),
            const SizedBox(width: 10),
            const Text('Detail Antrean'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'NOMOR ANTREAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      antrian.nomorFD.toString().padLeft(3, '0'),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Nama', antrian.nama, isDark),
            const Divider(height: 24),
            _buildDetailRow('Tujuan', antrian.subSatker, isDark),
            const Divider(height: 24),
            _buildDetailRow('Durasi', '${antrian.durasi} Hari', isDark),
            const Divider(height: 24),
            _buildDetailRow(
              'Waktu',
              dateFormat.format(antrian.createdAt),
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AntrianProvider>();
    final isDark = provider.isDarkMode;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Riwayat Antrean'),
            if (_selectedDate != null)
              Text(
                DateFormat('d MMM yyyy', 'id_ID').format(_selectedDate!),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
        elevation: 0.5,
        actions: [
          if (_selectedDate != null)
            IconButton(
              onPressed: _clearFilter,
              icon: const Icon(Icons.filter_list_off_rounded),
              tooltip: 'Hapus Filter',
            ),
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Filter Tanggal',
          ),
          IconButton(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                    _selectedDate == null
                        ? 'Belum ada riwayat antrean'
                        : 'Tidak ada data pada tanggal ini',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _clearFilter,
                      child: const Text('Tampilkan Semua'),
                    ),
                  ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allHistory.length,
                  itemBuilder: (context, index) {
                    final antrian = _allHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF2D3A55)
                              : AppTheme.borderColor,
                        ),
                      ),
                  child: InkWell(
                    onTap: () => _showDetailDialog(antrian),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                antrian.nomorFD.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  antrian.nama,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.business_rounded,
                                      size: 14,
                                      color: isDark
                                          ? Colors.white54
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      antrian.subSatker,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white70
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: isDark
                                          ? Colors.white54
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${antrian.durasi} Hari',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white70
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                dateFormat.format(antrian.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white54
                                      : AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade300,
                              ),
                            ],
                          ),
                        ],
                      ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
