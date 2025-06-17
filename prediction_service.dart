import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  static Future<String> predictTriage({
    required double suhuTubuh,
    required int detakJantung,
    required int tekananDarahSistolik,
    required int tekananDarahDiastolik,
    required int lajuPernapasan,
    required int saturasiOksigen,
    required String kondisi,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://YOUR_SERVER_IP:5000/predict'), // Update with your server IP
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'suhu_tubuh': suhuTubuh,
          'detak_jantung': detakJantung,
          'tekanan_darah_sistolik': tekananDarahSistolik,
          'tekanan_darah_diastolik': tekananDarahDiastolik,
          'laju_pernapasan': lajuPernapasan,
          'saturasi_oksigen': saturasiOksigen,
          'kondisi': kondisi,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['prediction'];
      } else {
        // Fallback to rule-based if API fails
        return _fallbackPrediction(
          suhuTubuh: suhuTubuh,
          detakJantung: detakJantung,
          tekananDarahSistolik: tekananDarahSistolik,
          tekananDarahDiastolik: tekananDarahDiastolik,
          lajuPernapasan: lajuPernapasan,
          saturasiOksigen: saturasiOksigen,
          kondisi: kondisi,
        );
      }
    } catch (e) {
      // Fallback to rule-based if exception occurs
      return _fallbackPrediction(
        suhuTubuh: suhuTubuh,
        detakJantung: detakJantung,
        tekananDarahSistolik: tekananDarahSistolik,
        tekananDarahDiastolik: tekananDarahDiastolik,
        lajuPernapasan: lajuPernapasan,
        saturasiOksigen: saturasiOksigen,
        kondisi: kondisi,
      );
    }
  }

  // Keep your original rule-based prediction as fallback
  static String _fallbackPrediction({
    required double suhuTubuh,
    required int detakJantung,
    required int tekananDarahSistolik,
    required int tekananDarahDiastolik,
    required int lajuPernapasan,
    required int saturasiOksigen,
    required String kondisi,
  }) {
    int skor = 0;
    
    if (suhuTubuh > 38 || suhuTubuh < 36) skor++;
    if (detakJantung > 100 || detakJantung < 60) skor++;
    if (tekananDarahSistolik > 140 || tekananDarahSistolik < 90) skor++;
    if (tekananDarahDiastolik > 90 || tekananDarahDiastolik < 60) skor++;
    if (lajuPernapasan > 20 || lajuPernapasan < 12) skor++;
    if (saturasiOksigen < 95) skor++;
    if (kondisi.toLowerCase().contains("kritis")) skor += 2;
    
    if (skor >= 5) {
      return "Merah";
    } else if (skor >= 3) {
      return "Kuning";
    } else {
      return "Hijau";
    }
  }
}