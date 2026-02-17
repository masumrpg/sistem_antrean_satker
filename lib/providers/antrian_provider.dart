import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../core/app_constants.dart';
import '../core/database_helper.dart';
import '../models/antrian_model.dart';

class AntrianProvider extends ChangeNotifier {
  // Form state
  String _nama = '';
  String _selectedSubSatker = '';
  int _nomorFD = 1;
  int _lastAutoFD = 0;
  int _durasi = AppConstants.defaultDurasi;
  bool _isAutoFD = true;
  bool _isDarkMode = false;
  String _judul = '';
  String _nominal = '';
  String _noSpm = '';
  bool _keepNama = false;

  // Printer
  bool _isPrinterConnected = false;

  // History
  List<Antrian> _history = [];

  // Getters
  String get nama => _nama;
  String get selectedSubSatker => _selectedSubSatker;
  int get nomorFD => _nomorFD;
  int get durasi => _durasi;
  bool get isAutoFD => _isAutoFD;
  bool get isDarkMode => _isDarkMode;
  bool get isPrinterConnected => _isPrinterConnected;
  List<Antrian> get history => _history;
  String get judul => _judul;
  String get nominal => _nominal;
  String get noSpm => _noSpm;
  bool get keepNama => _keepNama;

  String get formattedNominal {
    if (_nominal.isEmpty) return '0';
    try {
      final cleanVal = _nominal.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanVal.isEmpty) return '0';
      final value = int.parse(cleanVal);
      return NumberFormat.decimalPattern('id_ID').format(value);
    } catch (_) {
      return _nominal;
    }
  }

  static String formatNominalValue(String? val) {
    if (val == null || val.isEmpty) return '0';
    try {
      final cleanVal = val.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanVal.isEmpty) return '0';
      final value = int.parse(cleanVal);
      return NumberFormat.decimalPattern('id_ID').format(value);
    } catch (_) {
      return val;
    }
  }

  String get nomorFDFormatted => _nomorFD.toString().padLeft(3, '0');

  bool get isFormValid => _nama.isNotEmpty && _selectedSubSatker.isNotEmpty;

  // Initialize
  Future<void> initialize() async {
    final db = DatabaseHelper.instance;
    _lastAutoFD = await db.getLastFDNumber();
    _nomorFD = _lastAutoFD + 1;
    _history = (await db.getAntrianToday()).map((e) => Antrian.fromMap(e)).toList();
    await _checkPrinter();
    notifyListeners();
  }

  Future<void> cetakStrukUlang(Antrian antrian) async {
    final pdfDoc = await _generatePdf(antrian);

    await Printing.layoutPdf(
      onLayout: (_) => pdfDoc.save(),
      name:
          'Struk-${antrian.nomorFD.toString().padLeft(3, '0')}-${DateFormat('ddMMyyyy').format(antrian.createdAt)}-REPRINT',
      format: PdfPageFormat(
        72 * PdfPageFormat.mm,
        200 * PdfPageFormat.mm,
        marginAll: 5 * PdfPageFormat.mm,
      ),
    );
  }

  // Setters
  void setNama(String value) {
    _nama = value;
    notifyListeners();
  }

  void setSubSatker(String value) {
    _selectedSubSatker = value;
    notifyListeners();
  }

  void setJudul(String value) {
    _judul = value;
    notifyListeners();
  }

  void setNominal(String value) {
    _nominal = value;
    notifyListeners();
  }

  void setNoSpm(String value) {
    _noSpm = value;
    notifyListeners();
  }

  void setKeepNama(bool value) {
    _keepNama = value;
    notifyListeners();
  }

  void setNomorFD(int value) {
    if (value >= 1) {
      _nomorFD = value;
      notifyListeners();
    }
  }

  void setNomorFDFromString(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 1) {
      _nomorFD = parsed;
      notifyListeners();
    }
  }

  void setDurasi(int value) {
    if (value >= AppConstants.minDurasi && value <= AppConstants.maxDurasi) {
      _durasi = value;
      notifyListeners();
    }
  }

  void setDurasiFromString(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 1) {
      _durasi = parsed;
      notifyListeners();
    }
  }

  void toggleAutoFD() {
    _isAutoFD = !_isAutoFD;
    if (_isAutoFD) {
      _nomorFD = _lastAutoFD + 1;
    }
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void incrementDurasi() {
    if (_durasi < AppConstants.maxDurasi) {
      _durasi++;
      notifyListeners();
    }
  }

  void decrementDurasi() {
    if (_durasi > AppConstants.minDurasi) {
      _durasi--;
      notifyListeners();
    }
  }

  Future<void> resetAll() async {
    _nama = '';
    _selectedSubSatker = '';
    _durasi = AppConstants.defaultDurasi;
    _nomorFD = 1;
    // Reset FD counter in DB to 0 (next will be 1)
    final db = DatabaseHelper.instance;
    await db.saveLastFDNumber(0);
    notifyListeners();
  }

  Future<void> _checkPrinter() async {
    try {
      final printers = await Printing.listPrinters();
      _isPrinterConnected = printers.isNotEmpty;
    } catch (_) {
      _isPrinterConnected = false;
    }
    notifyListeners();
  }

  Future<int> findNextAvailableFD(int start) async {
    final db = DatabaseHelper.instance;
    int current = start;
    while (await db.isFDUsedToday(current)) {
      current++;
    }
    return current;
  }

  // Print & Save
  Future<void> cetakStruk(BuildContext context) async {
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final db = DatabaseHelper.instance;

    // Check if FD is unique for today
    bool isUsed = await db.isFDUsedToday(_nomorFD);
    if (isUsed) {
      if (_isAutoFD) {
        // If auto, find next available
        _nomorFD = await findNextAvailableFD(_nomorFD);
        isUsed = false;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nomor FD $_nomorFD sudah ada untuk hari ini. Silahkan gunakan nomor lain.',
              ),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'CARI SELANJUTNYA',
                textColor: Colors.white,
                onPressed: () async {
                  _nomorFD = await findNextAvailableFD(_nomorFD);
                  notifyListeners();
                },
              ),
            ),
          );
        }
        return;
      }
    }

    final antrian = Antrian(
      nama: _nama,
      subSatker: _selectedSubSatker,
      nomorFD: _nomorFD,
      durasi: _durasi,
      judul: _judul,
      nominal: _nominal,
      createdAt: DateTime.now(),
    );

    // Save to database
    await db.insertAntrian(antrian.toMap());

    if (_isAutoFD) {
      _lastAutoFD = _nomorFD;
      await db.saveLastFDNumber(_lastAutoFD);
    }

    // Generate & print PDF
    final pdfDoc = await _generatePdf(antrian);

    await Printing.layoutPdf(
      onLayout: (_) => pdfDoc.save(),
      name:
          'Struk-${antrian.nomorFD.toString().padLeft(3, '0')}-${DateFormat('ddMMyyyy').format(antrian.createdAt)}-IN',
      format: PdfPageFormat(
        72 * PdfPageFormat.mm,
        200 * PdfPageFormat.mm,
        marginAll: 5 * PdfPageFormat.mm,
      ),
    );

    // Auto-increment after printing
    if (_isAutoFD) {
      _nomorFD++;
      _lastAutoFD = _nomorFD - 1; // Update last auto FD
    }

    // Reset form
    if (!_keepNama) {
      _nama = '';
    }
    _judul = '';
    _nominal = '';
    _selectedSubSatker = '';
    _durasi = AppConstants.defaultDurasi;

    if (_isAutoFD) {
      _nomorFD = _lastAutoFD + 1;
    }

    _history = (await db.getAntrianToday())
        .map((e) => Antrian.fromMap(e))
        .toList();
    notifyListeners();
  }

  Future<Antrian?> findAntrianByFD(int fd, {DateTime? date}) async {
    final db = DatabaseHelper.instance;
    final map = await db.getAntrianByFD(fd, date: date);
    if (map != null) {
      final antrian = Antrian.fromMap(map);
      // Only return if it's still 'IN' (deposits ready to be picked up)
      if (antrian.status == 'IN') {
        return antrian;
      }
    }
    return null;
  }

  Future<Antrian?> processOut(
    int nomorFD,
    String takerName,
    String takerSatker,
    String noSpm, {
    DateTime? date,
  }) async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now();
    final searchDate = date ?? now;

    final count = await db.updateAntrianStatus(
      nomorFD,
      searchDate,
      'OUT',
      now,
      takerName,
      takerSatker,
      noSpm,
    );

    if (count > 0) {
      // Fetch the updated item
      final updatedItemMap = await db.getAntrianByFD(nomorFD, date: searchDate);
      if (updatedItemMap != null) {
        final updatedItem = Antrian.fromMap(updatedItemMap);

        // Refresh history
        _history = (await db.getAntrianToday())
            .map((e) => Antrian.fromMap(e))
            .toList();
        notifyListeners();
        return updatedItem;
      }
    }
    return null;
  }

  Future<pw.Document> _generatePdf(Antrian antrian) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');

    // PDF setup

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          72 * PdfPageFormat.mm,
          200 * PdfPageFormat.mm,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'SIASAT',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Sistem Antrean Satker',
                style: const pw.TextStyle(fontSize: 7),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'BUKTI PENITIPAN BERKAS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              pw.Text(
                'NOMOR ANTREAN',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  antrian.nomorFD.toString().padLeft(3, '0'),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              _buildPdfRow('No. FD', antrian.nomorFD.toString().padLeft(3, '0')),
              _buildPdfRow('Nama', antrian.nama),
              _buildPdfRow('Satker', antrian.subSatker),
              if (antrian.judul != null && antrian.judul!.isNotEmpty)
                _buildPdfRow('Judul', antrian.judul!),
              if (antrian.nominal != null && antrian.nominal!.isNotEmpty)
                _buildPdfRow(
                  'Nominal',
                  'Rp ${formatNominalValue(antrian.nominal)}',
                ),
              _buildPdfRow('Durasi', '${antrian.durasi} Hari'),
              _buildPdfRow(
                'Tgl. Penitipan',
                '${dateFormat.format(antrian.createdAt)} ${timeFormat.format(antrian.createdAt)}',
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 8),
              _buildPdfRow(
                'Tgl. Kembali',
                dateFormat.format(
                  antrian.createdAt.add(Duration(days: antrian.durasi)),
                ),
              ),
              if (antrian.status == Antrian.statusOut) ...[
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 8),
                pw.Text(
                  'INFORMASI PENGAMBILAN',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                _buildPdfRow('Diambil Oleh', antrian.takerName ?? '-'),
                _buildPdfRow('Dari Satker', antrian.takerSatker ?? '-'),
                _buildPdfRow('No. SPM', antrian.noSpm ?? '-'),
                _buildPdfRow(
                  'Waktu Ambil',
                  antrian.outAt != null
                      ? '${dateFormat.format(antrian.outAt!)} ${timeFormat.format(antrian.outAt!)}'
                      : '-',
                ),
              ],
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              pw.Text(
                'Harap bawa struk ini saat pengambilan berkas.',
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '© ${DateTime.now().year} SIASAT',
                style: const pw.TextStyle(
                  fontSize: 6,
                  color: PdfColors.grey600,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('$label:', style: const pw.TextStyle(fontSize: 8)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> resetAllData() async {
    await DatabaseHelper.instance.deleteAllAntrian();
    _history = [];
    _nomorFD = AppConstants.defaultFDStart;
    notifyListeners();
  }

  Future<void> exportData(String targetPath) async {
    await DatabaseHelper.instance.backupDatabase(targetPath);
  }

  Future<void> importData(String sourcePath) async {
    final db = DatabaseHelper.instance;
    await db.restoreDatabase(sourcePath);
    // Refresh history
    _history = (await db.getAntrianToday())
        .map((e) => Antrian.fromMap(e))
        .toList();
    notifyListeners();
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int value = int.parse(cleanText);
    final String formattedText = NumberFormat.decimalPattern(
      'id_ID',
    ).format(value);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
