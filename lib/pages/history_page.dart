import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../core/app_constants.dart';
import '../core/database_helper.dart';
import '../models/antrian_model.dart';
import '../providers/antrian_provider.dart';
import '../widgets/receipt_widget.dart';

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

  Future<void> _handleExport() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Database',
      fileName:
          'backup_siasat_${DateFormat('yyyyMMdd').format(DateTime.now())}.db',
      type: FileType.any,
    );

    if (result != null) {
      if (mounted) {
        try {
          await context.read<AntrianProvider>().exportData(result);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Database berhasil diekspor'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengekspor data: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _handleImport() async {
    // 1. Confirmation
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

    // 2. File Picking
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      if (mounted) {
        try {
          await context.read<AntrianProvider>().importData(
            result.files.single.path!,
          );
          await _loadHistory();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Database berhasil diimpor'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
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

  void _showDetailDialog(Antrian antrian) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Close Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail Antrean',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Receipt Widget
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ReceiptWidget(antrian: antrian, isPreview: true),
                ),
                // Footer info if OUT
                if (antrian.status == 'OUT' && antrian.takerName != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INFO PENGAMBILAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Diambil Oleh', antrian.takerName!),
                        const SizedBox(height: 4),
                        _buildInfoRow('Satker', antrian.takerSatker ?? '-'),
                        const SizedBox(height: 4),
                        _buildInfoRow('No. SPM', antrian.noSpm ?? '-'),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          'Waktu Ambil',
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                            'id_ID',
                          ).format(antrian.outAt!),
                        ),
                      ],
                    ),
                  ),
                // Re-print Button always available in detail
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AntrianProvider>().cetakStrukUlang(
                          antrian,
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('CETAK ULANG'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: BorderSide(color: AppTheme.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: antrian.status == 'IN'
            ? [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showTakeDialog(antrian);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('PROSES PENGAMBILAN'),
                    ),
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  void _showResetDialog(BuildContext context, AntrianProvider provider) {
    final textController = TextEditingController();
    bool isConfirmEnabled = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Reset Semua Data?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tindakan ini akan menghapus seluruh riwayat antrean secara permanen.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ketik "RESET" untuk mengonfirmasi:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'RESET',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (val) {
                  setState(() => isConfirmEnabled = val == 'RESET');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isConfirmEnabled
                  ? () async {
                      await provider.resetAllData();
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Seluruh data berhasil dihapus'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _loadHistory();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('RESET SEKARANG'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTakeDialog(Antrian antrian) {
    final nameController = TextEditingController();
    final satkerController = TextEditingController(text: antrian.subSatker);
    final spmController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Ambil Berkas'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pengambil',
                    hintText: 'Siapa yang mengambil berkas?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue:
                      AppConstants.subSatkerList.any(
                        (e) => e.name == satkerController.text,
                      )
                      ? satkerController.text
                      : AppConstants.subSatkerList.first.name,
                  decoration: const InputDecoration(
                    labelText: 'Satker Pengambil',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.subSatkerList.map((sub) {
                    return DropdownMenuItem(
                      value: sub.name,
                      child: Text(sub.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) satkerController.text = val;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: spmController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nomor SPM',
                    hintText: 'Masukkan Nomor SPM',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        final provider = context.read<AntrianProvider>();
                        final result = await provider.processOut(
                          antrian.nomorFD,
                          nameController.text,
                          satkerController.text,
                          spmController.text,
                        );

                        if (context.mounted) {
                          Navigator.pop(ctx); // Close take dialog
                          if (result != null) {
                            _showDetailDialog(result); // Show updated detail
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berkas berhasil diambil'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadHistory(); // Refresh list
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal memproses data'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 11)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AntrianProvider>();
    final isDark = provider.isDarkMode;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: TabBar(
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryBlue,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Belum Diambil'),
              Tab(text: 'Sudah Diambil'),
            ],
          ),
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
            IconButton(
              onPressed: _handleExport,
              icon: const Icon(Icons.upload_rounded),
              tooltip: 'Ekspor Data',
            ),
            IconButton(
              onPressed: _handleImport,
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Impor Data',
            ),
            IconButton(
              onPressed: () => _showResetDialog(context, provider),
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              tooltip: 'Reset Data',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildHistoryList(_allHistory, isDark),
                  _buildHistoryList(
                    _allHistory.where((e) => e.status == 'IN').toList(),
                    isDark,
                  ),
                  _buildHistoryList(
                    _allHistory.where((e) => e.status == 'OUT').toList(),
                    isDark,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHistoryList(List<Antrian> history, bool isDark) {
    if (history.isEmpty) {
      return Center(
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
              'Tidak ada data antrean',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final antrian = history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? const Color(0xFF2D3A55) : AppTheme.borderColor,
            ),
          ),
          child: InkWell(
            onTap: () => _showDetailDialog(antrian),
            borderRadius: BorderRadius.circular(12),
            hoverColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
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
                            color: isDark ? Colors.white : AppTheme.textPrimary,
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
                        if (antrian.status == 'OUT' &&
                            antrian.takerName != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_pin_rounded,
                                  size: 14,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'DIAMBIL OLEH: ${antrian.takerName} (${antrian.takerSatker ?? "-"})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat(
                          'dd MMM, HH:mm',
                          'id_ID',
                        ).format(antrian.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white54
                              : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: antrian.status == 'OUT'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: antrian.status == 'OUT'
                                ? Colors.green.withValues(alpha: 0.5)
                                : Colors.orange.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          antrian.status == 'OUT' ? 'DIAMBIL' : 'DITITIPKAN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: antrian.status == 'OUT'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
