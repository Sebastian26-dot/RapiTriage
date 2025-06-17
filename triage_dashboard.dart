import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'pasien.dart';

class TriageDashboard extends StatefulWidget {
  @override
  _TriageDashboardState createState() => _TriageDashboardState();
}

class _TriageDashboardState extends State<TriageDashboard> {
  List<Pasien> pasienList = [];
  Timer? _timer;
  Timer? _vitalSignsTimer;
  DateTime lastUpdated = DateTime.now();
  bool isRealTimeActive = true;

  // Real-time statistics
  Map<String, int> priorityCount = {'Merah': 0, 'Kuning': 0, 'Hijau': 0};
  int totalProcessedToday = 0;

  @override
  void initState() {
    super.initState();
    _generateDummyData();
    _startRealTimeSimulation();
    _startVitalSignsMonitoring();
    _updateStatistics();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vitalSignsTimer?.cancel();
    super.dispose();
  }

  void _generateDummyData() {
    pasienList = [
      Pasien(
        nama: 'Sebastian Darren',
        usia: 50,
        jenisKelamin: 'Laki-laki',
        suhuTubuh: 38.1,
        detakJantung: 119,
        lajuPernapasan: 29,
        tekananDarahSistolik: 146,
        tekananDarahDiastolik: 90,
        saturasiOksigen: 95,
        keluhan: 'Nyeri dada',
        kondisi: 'Berat',
        triagePriority: 'Merah',
        waktuMasuk: DateTime.now(),
      ),
      Pasien(
        nama: 'Mikhael Henokh',
        usia: 43,
        jenisKelamin: 'Laki-laki',
        suhuTubuh: 38.5,
        detakJantung: 88,
        lajuPernapasan: 27,
        tekananDarahSistolik: 132,
        tekananDarahDiastolik: 88,
        saturasiOksigen: 97,
        keluhan: 'Demam tinggi',
        kondisi: 'Sedang',
        triagePriority: 'Kuning',
        waktuMasuk: DateTime.now(),
      ),
      Pasien(
        nama: 'Dustin Manuel',
        usia: 33,
        jenisKelamin: 'Laki-laki',
        suhuTubuh: 36.8,
        detakJantung: 75,
        lajuPernapasan: 18,
        tekananDarahSistolik: 120,
        tekananDarahDiastolik: 80,
        saturasiOksigen: 98,
        keluhan: 'Batuk ringan',
        kondisi: 'Ringan',
        triagePriority: 'Hijau',
        waktuMasuk: DateTime.now(),
      ),
    ];
    _sortPasienByPriority();
  }

  // Priority queue sorting: Red -> Yellow -> Green, then by arrival time
  void _sortPasienByPriority() {
    pasienList.sort((a, b) {
      // First sort by priority (lower weight = higher priority)
      int priorityComparison = a.priorityWeight.compareTo(b.priorityWeight);
      if (priorityComparison != 0) {
        return priorityComparison;
      }
      // If same priority, sort by arrival time (earlier first)
      return a.waktuMasuk.compareTo(b.waktuMasuk);
    });
  }

  // REAL-TIME FEATURE: Simulate vital signs changes
  void _startVitalSignsMonitoring() {
    _vitalSignsTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!isRealTimeActive) return;

      setState(() {
        for (int i = 0; i < pasienList.length; i++) {
          // Simulate slight vital signs fluctuations for critical patients
          if (pasienList[i].triagePriority == 'Merah') {
            _simulateVitalSignsChange(i);
          }
        }
        lastUpdated = DateTime.now();
      });
    });
  }

  void _startRealTimeSimulation() {
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (!isRealTimeActive) return;

      setState(() {
        // Re-sort the queue to maintain priority order
        _sortPasienByPriority();
        _updateStatistics();
        lastUpdated = DateTime.now();
      });
    });
  }

  // REAL-TIME FEATURE: Simulate vital signs changes
  void _simulateVitalSignsChange(int index) {
    final pasien = pasienList[index];

    // Create new patient with slightly modified vital signs
    final modifiedPasien = Pasien(
      nama: pasien.nama,
      usia: pasien.usia,
      jenisKelamin: pasien.jenisKelamin,
      suhuTubuh: _fluctuateValue(pasien.suhuTubuh, 0.2, 35.0, 42.0),
      detakJantung:
          _fluctuateValue(
            pasien.detakJantung.toDouble(),
            5.0,
            40.0,
            180.0,
          ).round(),
      lajuPernapasan:
          _fluctuateValue(
            pasien.lajuPernapasan.toDouble(),
            2.0,
            8.0,
            40.0,
          ).round(),
      tekananDarahSistolik:
          _fluctuateValue(
            pasien.tekananDarahSistolik.toDouble(),
            5.0,
            80.0,
            200.0,
          ).round(),
      tekananDarahDiastolik:
          _fluctuateValue(
            pasien.tekananDarahDiastolik.toDouble(),
            3.0,
            40.0,
            120.0,
          ).round(),
      saturasiOksigen:
          _fluctuateValue(
            pasien.saturasiOksigen.toDouble(),
            1.0,
            85.0,
            100.0,
          ).round(),
      keluhan: pasien.keluhan,
      kondisi: pasien.kondisi,
      triagePriority: pasien.triagePriority,
      waktuMasuk: pasien.waktuMasuk,
    );

    pasienList[index] = modifiedPasien;
  }

  double _fluctuateValue(
    double current,
    double maxChange,
    double min,
    double max,
  ) {
    final random = Random();
    final change = (random.nextDouble() - 0.5) * 2 * maxChange;
    final newValue = current + change;
    return newValue.clamp(min, max);
  }

  // REAL-TIME FEATURE: Update statistics
  void _updateStatistics() {
    priorityCount = {'Merah': 0, 'Kuning': 0, 'Hijau': 0};

    for (final pasien in pasienList) {
      priorityCount[pasien.triagePriority] =
          (priorityCount[pasien.triagePriority] ?? 0) + 1;
    }
  }

  // Get queue position text
  String _getQueuePosition(int index) {
    return 'Antrian: ${index + 1}';
  }

  // Get priority badge with real-time indicator
  Widget _getPriorityBadge(String triagePriority) {
    Color color;
    String text;
    IconData icon;

    switch (triagePriority.toLowerCase()) {
      case 'merah':
        color = Colors.red;
        text = 'MERAH';
        icon = Icons.local_hospital;
        break;
      case 'kuning':
        color = Colors.orange;
        text = 'KUNING';
        icon = Icons.warning;
        break;
      case 'hijau':
        color = Colors.green;
        text = 'HIJAU';
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        text = 'UNKNOWN';
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (triagePriority == 'Merah') ...[
            SizedBox(width: 4),
            Icon(Icons.circle, color: Colors.white, size: 8),
          ],
        ],
      ),
    );
  }

  // Manual delete patient function
  void _deletePatient(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus pasien ${pasienList[index].nama}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  pasienList.removeAt(index);
                  totalProcessedToday++;
                  _updateStatistics();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pasien berhasil dihapus')),
                );
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // PERBAIKAN: Fungsi untuk menambah pasien baru
  void _addNewPatient(Pasien newPasien) {
    setState(() {
      pasienList.add(newPasien);
      _sortPasienByPriority(); // Re-sort after adding new patient
      _updateStatistics();
      lastUpdated = DateTime.now();
    });

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pasien ${newPasien.nama} berhasil ditambahkan (${newPasien.triagePriority})',
        ),
        backgroundColor: newPasien.priorityColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.white),
            SizedBox(width: 8),
            Text('RapiTriage'),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: false,
        actions: [
          // Real-time status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isRealTimeActive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRealTimeActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 12,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total: ${pasienList.length}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Toggle real-time button
          IconButton(
            onPressed: () {
              setState(() {
                isRealTimeActive = !isRealTimeActive;
              });
            },
            icon: Icon(isRealTimeActive ? Icons.pause : Icons.play_arrow),
          ),
        ],
      ),
      body: Column(
        children: [
          // Real-time statistics dashboard
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Priority Legend with live counts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(
                      Colors.red,
                      'MERAH',
                      '${priorityCount['Merah']} pasien',
                    ),
                    _buildLegendItem(
                      Colors.orange,
                      'KUNING',
                      '${priorityCount['Kuning']} pasien',
                    ),
                    _buildLegendItem(
                      Colors.green,
                      'HIJAU',
                      '${priorityCount['Hijau']} pasien',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Real-time stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Total Antrian', '${pasienList.length}'),
                    _buildStatItem('Diproses Hari Ini', '$totalProcessedToday'),
                    _buildStatItem('Update Terakhir', _formatLastUpdated()),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                pasienList.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada pasien dalam antrian',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Real-time monitoring aktif',
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: pasienList.length,
                      itemBuilder: (context, index) {
                        final pasien = pasienList[index];
                        return Card(
                          color: pasien.priorityBackgroundColor,
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with name and priority badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                pasien.nama,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (pasien.triagePriority ==
                                                  'Merah') ...[
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.monitor_heart,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            '${pasien.usia} tahun - ${pasien.jenisKelamin}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _getPriorityBadge(
                                          pasien.triagePriority,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          _getQueuePosition(index),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Vital signs in grid with real-time indicators
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        pasien.triagePriority == 'Merah'
                                            ? Border.all(
                                              color: Colors.red.withOpacity(
                                                0.5,
                                              ),
                                              width: 2,
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildVitalSign(
                                              'Suhu',
                                              '${pasien.suhuTubuh.toStringAsFixed(1)}°C',
                                              Icons.thermostat,
                                              isAbnormal:
                                                  pasien.suhuTubuh > 38 ||
                                                  pasien.suhuTubuh < 36,
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildVitalSign(
                                              'Nadi',
                                              '${pasien.detakJantung}/min',
                                              Icons.favorite,
                                              isAbnormal:
                                                  pasien.detakJantung > 100 ||
                                                  pasien.detakJantung < 60,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildVitalSign(
                                              'Napas',
                                              '${pasien.lajuPernapasan}/min',
                                              Icons.air,
                                              isAbnormal:
                                                  pasien.lajuPernapasan > 20 ||
                                                  pasien.lajuPernapasan < 12,
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildVitalSign(
                                              'SpO₂',
                                              '${pasien.saturasiOksigen}%',
                                              Icons.opacity,
                                              isAbnormal:
                                                  pasien.saturasiOksigen < 95,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      _buildVitalSign(
                                        'T.D',
                                        '${pasien.tekananDarahSistolik}/${pasien.tekananDarahDiastolik}',
                                        Icons.monitor_heart,
                                        isAbnormal:
                                            pasien.tekananDarahSistolik > 140 ||
                                            pasien.tekananDarahSistolik < 90,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 12),

                                // Complaint and action buttons
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Keluhan: ${pasien.keluhan}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Kondisi: ${pasien.kondisi}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed:
                                                () => _deletePatient(index),
                                            icon: Icon(Icons.delete, size: 16),
                                            label: Text('Selesai'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // PERBAIKAN: Menggunakan async/await yang benar
          final result = await Navigator.pushNamed(context, '/form');

          // Debug print untuk melihat apakah data kembali dari form
          print('Received result from form: $result');
          print('Result type: ${result.runtimeType}');

          if (result != null && result is Pasien) {
            print('Adding new patient: ${result.nama}');
            _addNewPatient(result);
          } else {
            print('No valid patient data received or form was cancelled');
          }
        },
        icon: Icon(Icons.person_add),
        label: Text('Tambah Pasien'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String priority, String count) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(height: 4),
        Text(
          priority,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          count,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildVitalSign(
    String label,
    String value,
    IconData icon, {
    bool isAbnormal = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isAbnormal ? Colors.red : Colors.grey.shade600,
        ),
        SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isAbnormal ? Colors.red : Colors.black,
          ),
        ),
        if (isAbnormal) ...[
          SizedBox(width: 4),
          Icon(Icons.warning, size: 12, color: Colors.red),
        ],
      ],
    );
  }

  String _formatLastUpdated() {
    final difference = DateTime.now().difference(lastUpdated);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}
