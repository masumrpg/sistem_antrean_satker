import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/app_constants.dart';
import '../providers/antrian_provider.dart';

class InputFormSection extends StatelessWidget {
  const InputFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AntrianProvider>();
    final isDark = provider.isDarkMode;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            _buildSectionTitle(
              icon: Icons.edit_note_rounded,
              title: 'INPUT FORM',
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Nama Pengunjung
            Text(
              'Nama Pengunjung',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: provider.setNama,
              decoration: const InputDecoration(
                hintText: 'Masukkan nama lengkap...',
              ),
              controller: TextEditingController(text: provider.nama)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: provider.nama.length),
                ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: provider.keepNama,
                    onChanged: (val) => provider.setKeepNama(val ?? false),
                    activeColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Simpan Nama (Jangan reset setelah cetak)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Judul
            Text(
              'Judul',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: provider.setJudul,
              decoration: const InputDecoration(
                hintText: 'Masukkan judul/keperluan...',
              ),
              controller: TextEditingController(text: provider.judul)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: provider.judul.length),
                ),
            ),
            const SizedBox(height: 16),

            // Nominal
            Text(
              'Nominal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: provider.setNominal,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: 'Masukkan nominal (jika ada)...',
                prefixText: 'Rp ',
              ),
              controller: TextEditingController(text: provider.nominal)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: provider.nominal.length),
                ),
            ),
            const SizedBox(height: 24),

            // Sub Satker
            _buildSectionTitle(
              icon: Icons.account_balance_rounded,
              title: 'SUB SATKER',
              isDark: isDark,
            ),
            const SizedBox(height: 14),
            _buildSubSatkerGrid(context, provider, isDark),
            const SizedBox(height: 24),

            // Nomor FD & Durasi Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor FD
                Expanded(
                  child: _buildNomorFDSection(context, provider, isDark),
                ),
                const SizedBox(width: 20),
                // Durasi
                Expanded(
                  child: _buildDurasiSection(context, provider, isDark),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Cetak & Reset Buttons
            Row(
              children: [
                // Reset Button
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _showResetConfirmation(context, provider),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('RESET'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Cetak Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _handlePrint(context, provider),
                      icon: const Icon(Icons.print_rounded, size: 20),
                      label: const Text('SIMPAN & CETAK NOMOR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!provider.isPrinterConnected)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Printer tidak terdeteksi, namun Anda tetap bisa mencoba mencetak (System Print).',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryBlue,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePrint(
    BuildContext context,
    AntrianProvider provider,
  ) async {
    final hasConflict = await provider.checkFDConflict(provider.nomorFD);
    if (hasConflict) {
      if (context.mounted) {
        _showConflictDialog(context, provider);
      }
    } else {
      if (context.mounted) {
        await provider.cetakStruk(context);
      }
    }
  }

  void _showConflictDialog(
    BuildContext context,
    AntrianProvider provider,
  ) async {
    final nextAvailable = await provider.findNextAvailableFD();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nomor FD Sudah Terpakai'),
        content: Text(
          'Nomor FD ${provider.nomorFD} sudah ada untuk hari ini.\n'
          'Saran nomor terkecil yang tersedia: $nextAvailable',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setNomorFD(nextAvailable);
              Navigator.pop(ctx);
              provider.cetakStruk(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: Text('GUNAKAN NOMOR $nextAvailable'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSatkerGrid(
    BuildContext context,
    AntrianProvider provider,
    bool isDark,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.0,
      children: AppConstants.subSatkerList.map((satker) {
        final isSelected = provider.selectedSubSatker == satker.name;
        return _SubSatkerButton(
          satker: satker,
          isSelected: isSelected,
          isDark: isDark,
          onTap: () => provider.setSubSatker(satker.name),
        );
      }).toList(),
    );
  }

  Widget _buildNomorFDSection(
    BuildContext context,
    AntrianProvider provider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.tag_rounded,
          title: 'NOMOR FD',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF2D3A55) : AppTheme.borderColor,
            ),
          ),
          child: Row(
            children: [
              // Toggle
              GestureDetector(
                onTap: provider.toggleAutoFD,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: provider.isAutoFD
                        ? AppTheme.primaryBlue
                        : Colors.grey.shade400,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: provider.isAutoFD
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Otomatis/Manual',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                  ),
                ),
              ),
              // Number display
              provider.isAutoFD
                  ? Text(
                      provider.nomorFDFormatted,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minus button
                        _SmallStepperButton(
                          icon: Icons.remove,
                          onTap: () =>
                              provider.setNomorFD(provider.nomorFD - 1),
                          enabled: provider.nomorFD > 1,
                        ),
                        const SizedBox(width: 6),
                        // Editable number
                        SizedBox(
                          width: 54,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: provider.setNomorFDFromString,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlue,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            controller: TextEditingController(
                              text: provider.nomorFDFormatted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Plus button
                        _SmallStepperButton(
                          icon: Icons.add,
                          onTap: () =>
                              provider.setNomorFD(provider.nomorFD + 1),
                          enabled: true,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurasiSection(
    BuildContext context,
    AntrianProvider provider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.schedule_rounded,
          title: 'DURASI (HARI)',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF2D3A55) : AppTheme.borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus button
              _StepperButton(
                icon: Icons.remove,
                onTap: provider.decrementDurasi,
                enabled: provider.durasi > AppConstants.minDurasi,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDurasiInputDialog(context, provider),
                  child: Text(
                    '${provider.durasi}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              // Plus button
              _StepperButton(
                icon: Icons.add,
                onTap: provider.incrementDurasi,
                enabled: provider.durasi < AppConstants.maxDurasi,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDurasiInputDialog(
      BuildContext context, AntrianProvider provider) {
    final controller =
        TextEditingController(text: provider.durasi.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Input Durasi (Hari)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Masukkan jumlah hari',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setDurasiFromString(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, AntrianProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 48,
        ),
        title: const Text(
          'Reset Semua Data?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Semua data input akan direset ke nilai awal. Apakah Anda yakin?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              provider.resetAll();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SubSatkerButton extends StatelessWidget {
  final SubSatker satker;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SubSatkerButton({
    required this.satker,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        mouseCursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue
                : isDark
                    ? const Color(0xFF1E2A45)
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : isDark
                      ? const Color(0xFF2D3A55)
                      : AppTheme.borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  satker.icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  satker.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? Colors.white70
                            : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.primaryBlue
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _SmallStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _SmallStepperButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: enabled ? AppTheme.primaryBlue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
