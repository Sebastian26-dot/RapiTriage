import 'package:flutter/material.dart';
import 'pasien.dart';
import 'prediction_service.dart';

class TriageForm extends StatefulWidget {
  const TriageForm({super.key}); // Simplified using super parameter

  @override
  TriageFormState createState() => TriageFormState();
}

class TriageFormState extends State<TriageForm> {
  final _formKey = GlobalKey<FormState>();

  String nama = '';
  int usia = 0; // Fixed: changed from umur to usia to match Pasien class
  String jenisKelamin = 'Laki-laki';
  double suhuTubuh = 0;
  int detakJantung = 0;
  int tekananDarahSistolik = 0;
  int tekananDarahDiastolik = 0;
  int lajuPernapasan = 0;
  int saturasiOksigen = 0;
  String keluhan = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Triage Pasien')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama'),
                validator:
                    (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                onSaved: (value) => nama = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Usia',
                ), // Fixed: changed from Umur to Usia
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Usia wajib diisi'
                            : null, // Fixed: changed from Umur to Usia
                onSaved:
                    (value) =>
                        usia = int.parse(
                          value!,
                        ), // Fixed: changed from umur to usia
              ),
              DropdownButtonFormField<String>(
                value: jenisKelamin,
                decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                items:
                    ['Laki-laki', 'Perempuan']
                        .map(
                          (jk) => DropdownMenuItem(value: jk, child: Text(jk)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => jenisKelamin = value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Suhu Tubuh (°C)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator:
                    (value) => value!.isEmpty ? 'Suhu wajib diisi' : null,
                onSaved: (value) => suhuTubuh = double.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Detak Jantung (/menit)',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Detak jantung wajib diisi' : null,
                onSaved: (value) => detakJantung = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tekanan Darah Sistolik',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Tekanan darah sistolik wajib diisi'
                            : null,
                onSaved: (value) => tekananDarahSistolik = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tekanan Darah Diastolik',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Tekanan darah diastolik wajib diisi'
                            : null,
                onSaved: (value) => tekananDarahDiastolik = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Laju Pernapasan (/menit)',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Laju pernapasan wajib diisi' : null,
                onSaved: (value) => lajuPernapasan = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Saturasi Oksigen (%)'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Saturasi oksigen wajib diisi' : null,
                onSaved: (value) => saturasiOksigen = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Keluhan'),
                maxLines: 3,
                validator:
                    (value) => value!.isEmpty ? 'Keluhan wajib diisi' : null,
                onSaved: (value) => keluhan = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Use PredictionService to determine kondisi
                    String triagePriority =
                        await PredictionService.predictTriage(
                          suhuTubuh: suhuTubuh,
                          detakJantung: detakJantung,
                          tekananDarahSistolik: tekananDarahSistolik,
                          tekananDarahDiastolik: tekananDarahDiastolik,
                          lajuPernapasan: lajuPernapasan,
                          saturasiOksigen: saturasiOksigen,
                          kondisi: keluhan,
                        );

                    // Convert triage prediction to condition level
                    String kondisiLevel;
                    switch (triagePriority) {
                      case 'Merah':
                        kondisiLevel = 'Berat';
                        break;
                      case 'Kuning':
                        kondisiLevel = 'Sedang';
                        break;
                      case 'Hijau':
                        kondisiLevel = 'Ringan';
                        break;
                      default:
                        kondisiLevel = 'Ringan';
                        triagePriority = 'Hijau';
                    }

                    final pasienBaru = Pasien(
                      nama: nama,
                      usia: usia, // Fixed: changed from umur to usia
                      jenisKelamin: jenisKelamin,
                      suhuTubuh: suhuTubuh,
                      detakJantung: detakJantung,
                      tekananDarahSistolik: tekananDarahSistolik,
                      tekananDarahDiastolik: tekananDarahDiastolik,
                      lajuPernapasan: lajuPernapasan,
                      saturasiOksigen: saturasiOksigen,
                      keluhan: keluhan, // Added missing keluhan field
                      kondisi:
                          kondisiLevel, // Added kondisi based on prediction
                      triagePriority: triagePriority, // Added triage priority
                    );
                    Navigator.pop(context, pasienBaru);
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
