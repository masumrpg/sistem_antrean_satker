class Antrian {
  final int? id;
  final String nama;
  final String subSatker;
  final int nomorFD;
  final int durasi;
  final DateTime createdAt;
  final String status; // 'IN' or 'OUT'
  final DateTime? outAt;
  final String? takerName;
  final String? takerSatker;

  static const String statusIn = 'IN'; // Penitipan
  static const String statusOut = 'OUT'; // Pengambilan

  bool get isWaiting => status == statusIn;
  final String? judul;
  final String? nominal;
  final String? noSpm;
  bool get isTaken => status == statusOut;

  Antrian({
    this.id,
    required this.nama,
    required this.subSatker,
    required this.nomorFD,
    required this.durasi,
    required this.createdAt,
    this.status = 'IN',
    this.outAt,
    this.takerName,
    this.takerSatker,
    this.judul,
    this.nominal,
    this.noSpm,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'sub_satker': subSatker,
      'nomor_fd': nomorFD,
      'durasi': durasi,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'out_at': outAt?.toIso8601String(),
      'taker_name': takerName,
      'taker_satker': takerSatker,
      'judul': judul,
      'nominal': nominal,
      'no_spm': noSpm,
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
      status: map['status'] as String? ?? 'IN',
      outAt: map['out_at'] != null
          ? DateTime.parse(map['out_at'] as String)
          : null,
      takerName: map['taker_name'] as String?,
      takerSatker: map['taker_satker'] as String?,
      judul: map['judul'] as String?,
      nominal: map['nominal'] as String?,
      noSpm: map['no_spm'] as String?,
    );
  }
}
