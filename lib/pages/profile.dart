import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class ProfilePage extends StatefulWidget { 
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> { 
  final Color primaryBlue = const Color.fromARGB(255, 68, 119, 248);
  String _currentUsername = 'Memuat...'; 

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentUsername = prefs.getString('currentUsername') ?? 'Pengguna';
      });
    }
  }
  
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('currentUsername');
    await prefs.remove('role');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundColor: primaryBlue.withOpacity(0.1),
               backgroundImage: const AssetImage('assets/fotoku.jpg'),
            ),
            const SizedBox(height: 15),

            Text(
              _currentUsername, 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _logout,
            ),
            const Divider(),
            
            const SizedBox(height: 20),

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home'); 
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/ringkasan'); 
              break;
            case 2:
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