
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

  // Fungsi utilitas untuk MENGAMANKAN konversi integer
  // Ini mencegah error "type 'Null' is not a subtype of type 'int'"
  static int _safeParseInt(dynamic data) {
    if (data == null) return 0; // Mengubah NULL menjadi 0
    if (data is int) return data; // Jika sudah int, langsung gunakan
    
    // Jika berupa string (misalnya "12000"), coba parse. Jika gagal, return 0.
    if (data is String) {
      return int.tryParse(data) ?? 0;
    }
    
    // Untuk tipe num (seperti double 10.0), konversi ke int
    if (data is num) return data.toInt();
    
    // Default fallback
    return 0;
  }

  // Digunakan untuk mengonversi JSON response dari API ke objek Layanan
  factory Layanan.fromJson(Map<String, dynamic> json) {
    return Layanan(
      id: _safeParseInt(json['id']), // Menggunakan fungsi aman
      nama: json['nama'] as String? ?? 'Nama Tidak Ada',
      deskripsi: json['deskripsi'] as String? ?? 'Deskripsi Tidak Ada',
      hewan: json['hewan'] as String? ?? 'Hewan Tidak Ada',
      harga: _safeParseInt(json['harga']), // MENGGUNAKAN FUNGSI AMAN UNTUK HARGA
      gambar: List<String>.from(json['gambar'] as List<dynamic>? ?? []),
    );
  }

  // Digunakan di HomePage untuk mengirim data ke rute DetailPenitipanPage
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

  // Digunakan di DetailPenitipanPage untuk mengonversi data rute (Map) kembali menjadi objek Layanan
  factory Layanan.fromMap(Map<String, dynamic> map) {
    return Layanan(
      id: _safeParseInt(map['id']), // Menggunakan fungsi aman
      nama: map['nama'] as String? ?? 'Nama Tidak Ada',
      deskripsi: map['deskripsi'] as String? ?? 'Deskripsi Tidak Ada',
      hewan: map['hewan'] as String? ?? 'Hewan Tidak Ada',
      harga: _safeParseInt(map['harga']), // MENGGUNAKAN FUNGSI AMAN UNTUK HARGA
      gambar: List<String>.from(map['gambar'] as List<dynamic>? ?? []),
    );
  }
}
