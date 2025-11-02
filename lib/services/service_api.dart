import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String apiKey = 'f8bb1ce31a90d746cae0a691';

  Future<double> getKurs(String targetCurrency) async {
    final url = Uri.parse('https://v6.exchangerate-api.com/v6/$apiKey/latest/IDR');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = data['conversion_rates'][targetCurrency]; // ⚠️ perhatikan key-nya
        if (rate == null) {
          throw Exception('Mata uang $targetCurrency tidak ditemukan');
        }
        return (rate as num).toDouble();
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil kurs: $e');
    }
  }
}
