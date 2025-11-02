import 'package:hive_flutter/hive_flutter.dart';
import '../model/pemesanan_model.dart'; // Impor model Pesanan

class PemesananService {
  
  // 1. Akses Box (TIDAK MEMBUKA LAGI)
  // Pastikan nama 'pesananbox' sesuai persis dengan yang dibuka di main.dart
  final Box<Pesanan> _box = Hive.box<Pesanan>('pesananbox'); // ⬅ DIUBAH MENJADI HURUF KECIL 'b'

  // 2. Ubah tipe data input menjadi objek Pesanan
  Future<void> simpanPemesanan(Pesanan pesanan) async {
    await _box.add(pesanan);
  }

  // 3. Kembalikan List of Pesanan, bukan List of Map
  List<Pesanan> ambilSemuaPemesanan() {
    return _box.values.toList(); 
  }

  Future<void> hapusPemesanan(int index) async {
    await _box.deleteAt(index);
  }
  
  // Opsional: Mendapatkan key (ID unik Hive)
  List<dynamic> get keys => _box.keys.toList();
}