import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../model/layanan.dart';
import 'pemesanan.dart';

class DetailPenitipanPage extends StatefulWidget {
  final Map<String, dynamic> layananData;
  const DetailPenitipanPage({super.key, required this.layananData});

  @override
  State<DetailPenitipanPage> createState() => _DetailPenitipanPageState();
}

class _DetailPenitipanPageState extends State<DetailPenitipanPage> {
  final Color _primaryColor = const Color.fromARGB(255, 68, 119, 248);
  late Layanan _layanan;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _layanan = Layanan.fromMap(widget.layananData);
  }

  String _formatRupiah(int harga) {
    final String formattedPrice = harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $formattedPrice / Malam';
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryColor, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Future<void> _goToPemesanan() async {
    // 1️⃣ Cek GPS aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktifkan GPS terlebih dahulu')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin lokasi ditolak permanen')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    const double hotelLat = -7.759454636843537;
    const double hotelLng =  110.5508595819242;
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      hotelLat,
      hotelLng,
    );
    double distanceInKm = distance / 1000;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PemesananPage(
          layanan: _layanan,
          distanceInKm: distanceInKm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> gambarList = _layanan.gambar;
    final bool isCat = _layanan.hewan.toLowerCase() == 'kucing';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Galeri Gambar
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                child: gambarList.isNotEmpty
                    ? Image.network(
                        gambarList[_currentImageIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey, size: 80)),
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey)),
              ),
              if (gambarList.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            List.generate(gambarList.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: index == _currentImageIndex
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  gambarList[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error,
                                          stackTrace) =>
                                      Container(color: Colors.grey[300]),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_layanan.nama,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isCat ? Icons.catching_pokemon : Icons.pets,
                        size: 18,
                        color: isCat ? Colors.orange : Colors.blueGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Untuk ${_layanan.hewan}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isCat ? Colors.orange : Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text('Deskripsi Layanan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_layanan.deskripsi,
                      style: const TextStyle(fontSize: 15, height: 1.5)),
                  const Divider(height: 30),
                  const Text('Fasilitas Utama',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.check_circle_outline, 'Kandang Luas & Nyaman'),
                  _buildFeatureRow(Icons.local_dining, 'Termasuk Makanan Premium'),
                  _buildFeatureRow(Icons.videocam_outlined, 'Akses CCTV 24 Jam'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Harga Mulai',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  _formatRupiah(_layanan.harga),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _goToPemesanan,
                child: const Text(
                  'Pesan Sekarang',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
