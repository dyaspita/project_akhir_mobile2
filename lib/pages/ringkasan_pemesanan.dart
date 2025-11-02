import 'package:flutter/material.dart';
import '../model/pemesanan_model.dart';

class RingkasanPemesananPage extends StatelessWidget {
  const RingkasanPemesananPage({super.key});

  // Warna primer yang lebih netral untuk latar belakang
  final Color _cardColor = const Color(0xFFF0F4F8); // Light Blue-Grey background

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  }

  String _formatHarga(int harga, String currency) {
    if (currency == 'IDR') {
      final formatted = harga.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
      return '$currency $formatted';
    } else {
      return '$currency ${harga.toStringAsFixed(2)}';
    }
  }

  // Widget baris detail
  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                    fontSize: isTotal ? 16 : 14,
                    color: isTotal ? Colors.indigo.shade800 : Colors.black54)),
          ),
          const SizedBox(width: 10),
          Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
                  fontSize: isTotal ? 18 : 14,
                  color: isTotal ? Colors.indigo.shade800 : Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Pesanan? pesanan = ModalRoute.of(context)!.settings.arguments as Pesanan?;

    if (pesanan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ringkasan Pemesanan')),
        body: const Center(child: Text('Gagal memuat detail pesanan.')),
      );
    }

    final String hargaTerformat = _formatHarga(pesanan.totalHarga, pesanan.currency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Berhasil!'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Sukses
            const Text(
              'Terima kasih! Pesanan Anda telah dikonfirmasi. 🎉', // Teks diperbaiki
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 25),
            
            // Kartu Ringkasan (Tiket)
            Card(
              color: _cardColor, // Warna latar belakang kartu baru
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // JUDUL DAN ID BOOKING (Baris 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Detail Booking',
                            style: TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.w900, 
                                color: Colors.blue)),
                        // ID Booking di atas detail Pemesan
                        Text('ID: ${pesanan.idPemesanan.substring(0, 8)}', 
                            style: const TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ],
                    ),
                    
                    const Divider(height: 25, thickness: 1.5, color: Colors.blueGrey),

                    // DETAIL PEMESANAN
                    _buildDetailRow('Pemesan', pesanan.username),
                    _buildDetailRow('Nama Hewan', pesanan.namaHewan),
                    
                    const Divider(height: 10, thickness: 0.5, color: Colors.black12),

                    // DETAIL LAYANAN & JANGKA WAKTU
                    _buildDetailRow('Layanan', pesanan.namaLayanan),
                    _buildDetailRow('Jangka Waktu', '${pesanan.jumlahHari} hari'),
                    
                    const Divider(height: 20, thickness: 1.0, color: Colors.blueGrey),

                    // DETAIL WAKTU
                    _buildDetailRow('Pengantaran', 
                                    '${_formatDate(pesanan.hariPengantaran)} | ${pesanan.jamPengantaran.format(context)}'),
                    _buildDetailRow('Penjemputan', 
                                    '${_formatDate(pesanan.hariPenjemputan)} | ${pesanan.jamPenjemputan.format(context)}'),
                    
                    const Divider(height: 25, thickness: 2, color: Colors.blueGrey),

                    // TOTAL HARGA
                    _buildDetailRow('TOTAL HARGA', hargaTerformat, isTotal: true),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Peringatan Check-in (Perbaikan tampilan)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade300)
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Peringatan Penting: Tunjukkan tiket digital ini (ID Booking ${pesanan.idPemesanan.substring(0, 8)}) kepada staf kami saat Anda melakukan Check-in pada tanggal ${_formatDate(pesanan.hariPengantaran)}.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 13
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Kembali
            ElevatedButton.icon(
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )
          ],
        ),
      ),
    );
  }
}