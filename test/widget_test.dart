import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_antrean_satker/models/antrian_model.dart';

void main() {
  group('Antrian Model', () {
    test('toMap produces correct fields', () {
      final antrian = Antrian(
        nama: 'Budi Santoso',
        subSatker: 'Pusintelhan',
        nomorFD: 42,
        durasi: 3,
        createdAt: DateTime(2026, 2, 15, 10, 30),
      );

      final map = antrian.toMap();
      expect(map['nama'], 'Budi Santoso');
      expect(map['sub_satker'], 'Pusintelhan');
      expect(map['nomor_fd'], 42);
      expect(map['durasi'], 3);
      expect(map['created_at'], isNotEmpty);
    });

    test('fromMap roundtrips correctly', () {
      final original = Antrian(
        nama: 'Test',
        subSatker: 'Sekretariat',
        nomorFD: 1,
        durasi: 5,
        createdAt: DateTime(2026, 1, 1),
      );

      final restored = Antrian.fromMap({
        'id': 1,
        ...original.toMap(),
      });

      expect(restored.id, 1);
      expect(restored.nama, original.nama);
      expect(restored.subSatker, original.subSatker);
      expect(restored.nomorFD, original.nomorFD);
      expect(restored.durasi, original.durasi);
    });
  });
}
