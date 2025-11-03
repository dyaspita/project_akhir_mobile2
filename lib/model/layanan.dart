
class Layanan {
  final int id;
  final String nama;
  final String deskripsi;
  final String hewan;
  final int harga;
  final List<String> gambar;

  Layanan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.hewan,
    required this.harga,
    required this.gambar,
  });

  static int _safeParseInt(dynamic data) {
    if (data == null) return 0; 
    if (data is int) return data; 
    
    if (data is String) {
      return int.tryParse(data) ?? 0;
    }
    if (data is num) return data.toInt();
    return 0;
  }

  factory Layanan.fromJson(Map<String, dynamic> json) {
    return Layanan(
      id: _safeParseInt(json['id']), 
      nama: json['nama'] as String? ?? 'Nama Tidak Ada',
      deskripsi: json['deskripsi'] as String? ?? 'Deskripsi Tidak Ada',
      hewan: json['hewan'] as String? ?? 'Hewan Tidak Ada',
      harga: _safeParseInt(json['harga']), 
      gambar: List<String>.from(json['gambar'] as List<dynamic>? ?? []),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'hewan': hewan,
      'harga': harga,
      'gambar': gambar,
    };
  }

  factory Layanan.fromMap(Map<String, dynamic> map) {
    return Layanan(
      id: _safeParseInt(map['id']), 
      nama: map['nama'] as String? ?? 'Nama Tidak Ada',
      deskripsi: map['deskripsi'] as String? ?? 'Deskripsi Tidak Ada',
      hewan: map['hewan'] as String? ?? 'Hewan Tidak Ada',
      harga: _safeParseInt(map['harga']), 
      gambar: List<String>.from(map['gambar'] as List<dynamic>? ?? []),
    );
  }
}
