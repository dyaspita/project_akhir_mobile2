import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/pemesanan_model.dart';
import '../services/pemesanan_service.dart';
import 'ringkasan_pemesanan.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final PemesananService _pemesananService = PemesananService();
  List<Pesanan> _riwayat = [];
  final Color primaryBlue = const Color.fromARGB(255, 68, 119, 248);

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  void _loadRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUsername');
    final semuaData = _pemesananService.ambilSemuaPemesanan();
    final dataUser = semuaData.where((p) => p.username == username).toList();

    if (mounted) {
      setState(() {
        _riwayat = dataUser;
      });
    }
  }

  String _formatTanggal(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Riwayat Pemesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
      ),

      body: _riwayat.isEmpty
          ? const Center(
              child: Text(
                'Belum ada pemesanan.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _riwayat.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemBuilder: (context, index) {
                final pesanan = _riwayat[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      child: const Icon(Icons.pets, color: Colors.black54),
                    ),
                    title: Text(
                      pesanan.namaLayanan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      '${pesanan.namaHewan} • ${_formatTanggal(pesanan.hariPengantaran)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: Text(
                      '${pesanan.currency} ${pesanan.totalHarga}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RingkasanPemesananPage(),
                          settings: RouteSettings(arguments: pesanan),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, 
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
