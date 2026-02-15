class Antrian {
  final int? id;
  final String nama;
  final String subSatker;
  final int nomorFD;
  final int durasi;
  final DateTime createdAt;

  Antrian({
    this.id,
    required this.nama,
    required this.subSatker,
    required this.nomorFD,
    required this.durasi,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'sub_satker': subSatker,
      'nomor_fd': nomorFD,
      'durasi': durasi,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Antrian.fromMap(Map<String, dynamic> map) {
    return Antrian(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      subSatker: map['sub_satker'] as String,
      nomorFD: map['nomor_fd'] as int,
      durasi: map['durasi'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
