import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          date: antrian.createdAt,
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
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Cari Nama, Judul, atau Nominal...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                )
              : Column(
                  children: [
                    const Text('Riwayat Antrean'),
                    if (_selectedDate != null)
                      Text(
                        DateFormat(
                          'd MMM yyyy',
                          'id_ID',
                        ).format(_selectedDate!),
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
          leading: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                )
              : null,
          actions: [
            if (!_isSearching) ...[
              IconButton(
                onPressed: () => setState(() => _isSearching = true),
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Cari',
              ),
              IconButton(
                onPressed: () => setState(() => _isGridView = !_isGridView),
                icon: Icon(
                  _isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                ),
                tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
              ),
            ],
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
                  _buildContent(_allHistory, isDark),
                  _buildContent(
                    _allHistory.where((e) => e.status == 'IN').toList(),
                    isDark,
                  ),
                  _buildContent(
                    _allHistory.where((e) => e.status == 'OUT').toList(),
                    isDark,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildContent(List<Antrian> history, bool isDark) {
    // Apply Search Filter locally
    final filteredHistory = history.where((antrian) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final matchesNama = antrian.nama.toLowerCase().contains(query);
      final matchesJudul =
          antrian.judul?.toLowerCase().contains(query) ?? false;
      final matchesNominal =
          antrian.nominal?.toLowerCase().contains(query) ?? false;
      final matchesNumber =
          antrian.nomorFD.toString().contains(query) ||
          antrian.nomorFD.toString().padLeft(3, '0').contains(query);
      return matchesNama || matchesJudul || matchesNominal || matchesNumber;
    }).toList();

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty
                  ? Icons.history_toggle_off_rounded
                  : Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Tidak ada data antrean'
                  : 'Pencarian tidak ditemukan',
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

    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          mainAxisExtent: 240, // Slightly increased to accommodate more lines
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          final antrian = filteredHistory[index];
          return _buildHistoryCard(antrian, isDark, isGrid: true);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        final antrian = filteredHistory[index];
        return _buildHistoryCard(antrian, isDark, isGrid: false);
      },
    );
  }

  Widget _buildHistoryCard(
    Antrian antrian,
    bool isDark, {
    required bool isGrid,
  }) {
    final borderColor = isDark ? const Color(0xFF2D3A55) : AppTheme.borderColor;

    return Card(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () => _showDetailDialog(antrian),
        borderRadius: BorderRadius.circular(16),
        mouseCursor: SystemMouseCursors.click,
        hoverColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Queue Number Badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        antrian.nomorFD.toString().padLeft(3, '0'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          antrian.nama,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                antrian.subSatker,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  _buildStatusBadge(antrian.status),
                ],
              ),
              if (!isGrid) const SizedBox(height: 12) else const Spacer(),

              // Middle Info (Judul & Nominal)
              if ((antrian.judul != null && antrian.judul!.isNotEmpty) ||
                  (antrian.nominal != null && antrian.nominal!.isNotEmpty))
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      if (antrian.judul != null && antrian.judul!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                antrian.judul!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (antrian.judul != null &&
                          antrian.judul!.isNotEmpty &&
                          antrian.nominal != null &&
                          antrian.nominal!.isNotEmpty)
                        const SizedBox(height: 6),
                      if (antrian.nominal != null &&
                          antrian.nominal!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 14,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rp ${AntrianProvider.formatNominalValue(antrian.nominal)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              if (!isGrid)
                const SizedBox(height: 12)
              else
                const SizedBox(height: 8),

              // Bottom Info (Date & Duration)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM, HH:mm').format(antrian.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${antrian.durasi} Hari',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),

              // Taker Info for OUT status
              if (antrian.status == 'OUT' && antrian.takerName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Diambil oleh: ${antrian.takerName}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isOut = status == 'OUT';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOut ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOut ? Colors.green.shade200 : Colors.orange.shade200,
          width: 0.5,
        ),
      ),
      child: Text(
        isOut ? 'Sudah Diambil' : 'Belum Diambil',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: isOut ? Colors.green.shade800 : Colors.orange.shade800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
