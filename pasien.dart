import 'package:flutter/material.dart';

class Pasien {
  final String nama;
  final int usia;
  final String jenisKelamin;
  final double suhuTubuh;
  final int detakJantung;
  final int tekananDarahSistolik;
  final int tekananDarahDiastolik;
  final int lajuPernapasan;
  final int saturasiOksigen;
  final String kondisi;
  final String keluhan;
  final DateTime waktuMasuk; // Added timestamp for queue ordering
  final String triagePriority; // Added triage priority (Merah/Kuning/Hijau)

  Pasien({
    required this.nama,
    required this.usia,
    required this.jenisKelamin,
    required this.suhuTubuh,
    required this.detakJantung,
    required this.tekananDarahSistolik,
    required this.tekananDarahDiastolik,
    required this.lajuPernapasan,
    required this.saturasiOksigen,
    required this.kondisi,
    required this.keluhan,
    required this.triagePriority,
    DateTime? waktuMasuk,
  }) : waktuMasuk = waktuMasuk ?? DateTime.now();

  // Priority weight for sorting (lower number = higher priority)
  int get priorityWeight {
    switch (triagePriority.toLowerCase()) {
      case 'merah':
        return 1; // Highest priority
      case 'kuning':
        return 2; // Medium priority  
      case 'hijau':
        return 3; // Lowest priority
      default:
        return 4; // Unknown priority
    }
  }

  // Get priority color
  Color get priorityColor {
    switch (triagePriority.toLowerCase()) {
      case 'merah':
        return Colors.red;
      case 'kuning':
        return Colors.orange;
      case 'hijau':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get priority background color
  Color get priorityBackgroundColor {
    switch (triagePriority.toLowerCase()) {
      case 'merah':
        return Colors.red.shade100;
      case 'kuning':
        return Colors.orange.shade100;
      case 'hijau':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}