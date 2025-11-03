import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/layanan.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String JSON_URL =
      'https://raw.githubusercontent.com/dyaspita/penitipan_hewan_api/main/data_penitipan.json';

  final Color _primaryColor = const Color.fromARGB(255, 68, 119, 248);
  final Color _headerColor = const Color.fromARGB(255, 68, 119, 248);

  String _currentUsername = 'Pengguna';
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'semua';

  List<Layanan> _originalLayananList = [];
  List<Layanan> _filteredLayananList = [];
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchDataFuture = _fetchLayananFromGithub();
    _searchController.addListener(_filterLayanan);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLayanan);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLayananFromGithub() async {
    try {
      final response = await http.get(Uri.parse(JSON_URL));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jsonList = data['jenis_layanan'];

        final List<Layanan> fetchedList =
            jsonList.map((jsonItem) => Layanan.fromJson(jsonItem)).toList();

        if (mounted) {
          setState(() {
            _originalLayananList = fetchedList;
            _filterLayanan();
          });
        }
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server atau terjadi error JSON: $e');
    }
  }

  void _filterLayanan() {
    final String query = _searchController.text.toLowerCase();

    final List<Layanan> searchResults = _originalLayananList.where((layanan) {
      final isNameMatch = layanan.nama.toLowerCase().contains(query);
      return isNameMatch;
    }).toList();

    final List<Layanan> finalResults = searchResults.where((layanan) {
      if (_selectedFilter == 'semua') {
        return true;
      }
      return layanan.hewan.toLowerCase() == _selectedFilter;
    }).toList();

    if (mounted) {
      setState(() {
        _filteredLayananList = finalResults;
      });
    }
  }

  String _formatRupiah(int harga) {
    final String formattedPrice = harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $formattedPrice';
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

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
    } else if (index == 1) {
      setState(() => _selectedIndex = 1);
      Navigator.of(context).pushReplacementNamed('/riwayat');
    } else if (index == 2) {
      setState(() => _selectedIndex = 2);
      Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label.toLowerCase();
    String displayLabel =
        label.substring(0, 1).toUpperCase() + label.substring(1);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(displayLabel),
        selected: isSelected,
        selectedColor: _primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey[100],
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label.toLowerCase();
              _filterLayanan();
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Colors.black),
                        onPressed: () {},
                      ),
                      GestureDetector(
                        onTap: () => _onItemTapped(2),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color.fromARGB(255, 156, 214, 255),
                          child: Icon(Icons.person,
                              color: Color.fromARGB(255, 0, 28, 142), size: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: _headerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hai, $_currentUsername 👋',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          'Selamat datang di Tobi Pet Hotel, kami siap memberikan perawatan terbaik untuk hewan kesayangan Anda.',
                          style: TextStyle(
                              fontSize: 14, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari layanan',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua'),
                    _buildFilterChip('kucing'),
                    _buildFilterChip('anjing'),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: FutureBuilder<void>(
              future: _fetchDataFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_off,
                                color: Colors.red, size: 50),
                            const SizedBox(height: 10),
                            const Text('Gagal memuat data layanan.'),
                            Text('${snapshot.error}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: CircularProgressIndicator(color: _primaryColor),
                      ),
                    ),
                  );
                }

                if (_filteredLayananList.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text('Layanan tidak ditemukan.',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredLayananList[index];
                      final imageUrl =
                          item.gambar.isNotEmpty ? item.gambar[0] : '';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pushNamed(context, '/detail_penitipan',
                                arguments: item.toMap());
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  height: 100,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Center(
                                              child: Icon(Icons.broken_image,
                                                  color: Colors.grey, size: 50)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item.nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(item.deskripsi,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.hewan.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: item.hewan
                                                            .toLowerCase() ==
                                                        'kucing'
                                                    ? Colors.orange
                                                    : Colors.blueGrey)),
                                        Text(_formatRupiah(item.harga),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _primaryColor)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _filteredLayananList.length,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
