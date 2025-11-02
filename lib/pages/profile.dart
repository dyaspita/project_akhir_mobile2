import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan import ini!

class ProfilePage extends StatefulWidget { // UBAH MENJADI STATEFULWIDGET
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> { // Tambahkan State Class
  final Color primaryBlue = const Color.fromARGB(255, 68, 119, 248);
  String _currentUsername = 'Memuat...'; // State untuk menyimpan username

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Panggil fungsi untuk memuat data saat widget dibuat
  }

  // Fungsi untuk memuat username dari SharedPreferences
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // Ambil username yang tersimpan saat login, atau default 'Pengguna'
        _currentUsername = prefs.getString('currentUsername') ?? 'Pengguna';
      });
    }
  }
  
  // Fungsilogout (Bisa diambil dari HomePage)
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('currentUsername');
    await prefs.remove('role');
    if (mounted) {
      // Ganti '/login' dengan nama rute login yang sesuai di aplikasi kamu
      Navigator.of(context).pushReplacementNamed('/login'); 
    }
  }


  @override
  Widget build(BuildContext context) {
    // ... (Sisa kode build)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ), // Tambah AppBar agar ada tombol kembali (jika tidak menggunakan BottomNav)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Bagian Profil Dinamis
            CircleAvatar(
              radius: 60,
              backgroundColor: primaryBlue.withOpacity(0.1),
              child: Icon(Icons.person, size: 60, color: primaryBlue),
            ),
            const SizedBox(height: 15),

            // Tampilkan Username yang dimuat
            Text(
              _currentUsername, // GANTI DENGAN STATE
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            // HILANGKAN WIDGET NIM STATIC DI SINI JIKA TIDAK DIPERLUKAN
            const SizedBox(height: 30),

            // Tambahkan Tombol Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _logout,
            ),
            const Divider(),
            
            const SizedBox(height: 20),

            // Bagian Informasi Statis (Dosen, Kesan, Saran)
            _buildInfoCard(
              title: "Nama : Wahyu Dyas Puspitasari",
              subtitle: "NIM : 124230051",
              icon: Icons.book,
              color: primaryBlue,
            ),
            _buildInfoCard(
              title: "Kesan",
              subtitle: "Mata kuliah yang menurut saya sangat seru dan menantang yang memberikan sebuah pengalaman yang berharga ",
              icon: Icons.message,
              color: primaryBlue,
            ),
            _buildInfoCard(
              title: "Saran",
              subtitle: "Pembelajaran sudah bagus dan menarik, saran mungkin bisa ditambah sesi sharing dengan mahasiswa mengenai project masing-masing",
              icon: Icons.favorite,
              color: primaryBlue,
            ),
          ],
        ),
      ),
      // ... (BottomNavigationBar tetap sama)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              // Pastikan menggunakan pushReplacementNamed agar BottomNav di home berfungsi normal
              Navigator.of(context).pushReplacementNamed('/home'); 
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/ringkasan'); 

              break;
            case 2:
              // sudah di halaman profil
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
            label: 'Pemesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildInfoCard tetap sama)
  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}