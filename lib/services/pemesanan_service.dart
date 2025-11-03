import 'package:hive_flutter/hive_flutter.dart';
import '../model/pemesanan_model.dart'; 

class PemesananService {
  final Box<Pesanan> _box = Hive.box<Pesanan>('pesananbox');

  Future<void> simpanPemesanan(Pesanan pesanan) async {
    await _box.add(pesanan);
  }
  List<Pesanan> ambilSemuaPemesanan() {
    return _box.values.toList(); 
  }
  Future<void> hapusPemesanan(int index) async {
    await _box.deleteAt(index);
  }
    List<dynamic> get keys => _box.keys.toList();
}