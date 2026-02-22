import 'package:flutter/material.dart';

class SubSatker {
  final String name;
  final IconData icon;

  const SubSatker({required this.name, required this.icon});
}

class AppConstants {
  static const String appTitle = 'E-Tiket';
  static const String appSubtitle = 'Pelayanan Terpadu';
  static const String appVersion = 'v2.0';
  static const String receiptTitle = 'TANDA TERIMA BERKAS';

  static const List<SubSatker> subSatkerList = [
    SubSatker(name: 'Sekretariat', icon: Icons.business),
    SubSatker(name: 'Pusduk', icon: Icons.public),
    SubSatker(name: 'Pusintelhan', icon: Icons.security),
    SubSatker(name: 'Pusiber', icon: Icons.lan),
  ];

  static const int defaultFDStart = 1;
  static const int defaultDurasi = 3;
  static const int minDurasi = 1;
  // No max durasi limit
}
