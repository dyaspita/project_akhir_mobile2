import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/layanan.dart';
import '../model/pemesanan_model.dart'; 
import '../services/pemesanan_service.dart'; 
import '../services/service_api.dart'; 
import 'package:uuid/uuid.dart';

class PemesananPage extends StatefulWidget {
  final Layanan layanan;
  final double? distanceInKm;

  const PemesananPage({
    super.key,
    required this.layanan,
    this.distanceInKm,
  });

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  final Color _primaryColor = const Color.fromARGB(255, 68, 119, 248);
  final _formKey = GlobalKey<FormState>();
  final PemesananService _pemesananService = PemesananService();
  final CurrencyService _apiService = CurrencyService(); 

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _namaHewanController = TextEditingController();
  final TextEditingController _jumlahHariController = TextEditingController(text: '1');
  final TextEditingController _tanggalPengantaranController = TextEditingController();
  final TextEditingController _waktuPengantaranDisplayController = TextEditingController(text: '10:00');

  DateTime? _hariPenjemputan;
  TimeOfDay _jamPengantaran = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay get _jamPenjemputan => _jamPengantaran;

  String _zonaWaktu = 'WIB';
  String _currency = 'IDR';
  double _kurs = 1.0;
  late int _totalHarga;

  final List<String> _zonaList = ['WIB', 'WITA', 'WIT', 'London'];
  final List<String> _currencyList = ['IDR', 'USD', 'EUR', 'JPY'];

  @override
  void initState() {
    super.initState();
    _totalHarga = widget.layanan.harga;
    _jumlahHariController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _namaHewanController.dispose();
    _jumlahHariController.removeListener(_updateTotal);
    _jumlahHariController.dispose();
    _tanggalPengantaranController.dispose();
    _waktuPengantaranDisplayController.dispose();
    super.dispose();
  }

  /// 🔁 Konversi waktu antar zona
  TimeOfDay _convertTimeByZone(TimeOfDay originalTime, String fromZone, String toZone) {
    final offsets = {'WIB': 0, 'WITA': 1, 'WIT': 2, 'London': -7};
    final diff = (offsets[toZone] ?? 0) - (offsets[fromZone] ?? 0);

    int newHour = (originalTime.hour + diff) % 24;
    if (newHour < 0) newHour += 24;

    return TimeOfDay(hour: newHour, minute: originalTime.minute);
  }

  /// 🔄 Update total harga
  void _updateTotal() {
    final int hari = int.tryParse(_jumlahHariController.text) ?? 1;
    setState(() {
      // Perhitungan menggunakan harga dan kurs yang sudah dikalikan dengan hari
      _totalHarga = (widget.layanan.harga * hari * _kurs).round(); 
      _updateHariPenjemputan();
    });
  }

  /// 📅 Update hari penjemputan otomatis
  void _updateHariPenjemputan() {
    if (_tanggalPengantaranController.text.isEmpty) {
      setState(() => _hariPenjemputan = null);
      return;
    }
    try {
      final tanggal = DateTime.parse(_tanggalPengantaranController.text);
      final hari = int.tryParse(_jumlahHariController.text) ?? 1;
      setState(() => _hariPenjemputan = tanggal.add(Duration(days: hari)));
    } catch (_) {
      setState(() => _hariPenjemputan = null);
    }
  }

  /// 📆 Pilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2028),
    );
    if (picked != null) {
      _tanggalPengantaranController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _updateHariPenjemputan();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _jamPengantaran,
    );
    if (picked != null) {
      final converted = _convertTimeByZone(picked, 'WIB', _zonaWaktu); 
      setState(() {
        _jamPengantaran = converted;
        _waktuPengantaranDisplayController.text =
            '${converted.hour.toString().padLeft(2, '0')}:${converted.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  /// 💾 Simpan pesanan
  void _simpanPesanan() async {
    if (!_formKey.currentState!.validate() || _hariPenjemputan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pastikan semua field terisi dan tanggal pengantaran dipilih')),
      );
      return;
    }

    final uuid = const Uuid();
    final idPemesanan = uuid.v4();

    final int jumlahHari = int.tryParse(_jumlahHariController.text) ?? 1;
    final hariPengantaran = DateTime.parse(_tanggalPengantaranController.text);

    final pesanan = Pesanan(
      idPemesanan: idPemesanan,
      username: _usernameController.text,
      namaHewan: _namaHewanController.text,
      namaLayanan: widget.layanan.nama,
      jumlahHari: jumlahHari,
      hariPengantaran: hariPengantaran,
      hariPenjemputan: _hariPenjemputan!,
      jamPengantaran: _jamPengantaran,
      jamPenjemputan: _jamPenjemputan,
      currency: _currency,
      kurs: _kurs,
      totalHarga: _totalHarga,
      distanceInKm: widget.distanceInKm ?? 0.0,
    );

    // 1. Simpan pesanan ke database/service (sesuai implementasi Anda)
    await _pemesananService.simpanPemesanan(pesanan);

    // 2. Navigasi dan KIRIM DATA
    Navigator.of(context).pushReplacementNamed(
        '/ringkasan',
        arguments: pesanan, // ⬅ INI PERBAIKANNYA
    );
  }

  /// 💰 Format harga
  String _formatHarga(int harga) {
    if (_currency == 'IDR') {
      final formatted = harga.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
      return '$_currency $formatted';
    } else {
      return '$_currency ${harga.toStringAsFixed(2)}';
    }
  }

  /// 📅 Format tanggal tampilan
  String _formatDateOnly(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  }

  /// 🧱 TextField builder
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Pemesanan'),
        backgroundColor: _primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data Pemesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _buildTextField(
                _usernameController,
                'Nama Pemesan',
                validator: (v) => v!.isEmpty ? 'Nama pemesan harus diisi' : null,
              ),
              _buildTextField(
                _namaHewanController,
                'Nama Hewan',
                validator: (v) => v!.isEmpty ? 'Harus diisi' : null,
              ),
              _buildTextField(
                _jumlahHariController,
                'Jumlah Hari Menginap',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    (int.tryParse(v ?? '0') ?? 0) < 1 ? 'Min. 1 hari' : null,
              ),
              _buildTextField(
                _tanggalPengantaranController,
                'Tanggal Pengantaran',
                readOnly: true,
                validator: (v) => v!.isEmpty ? 'Pilih tanggal pengantaran' : null,
                onTap: () => _selectDate(context),
              ),
              _buildTextField(
                _waktuPengantaranDisplayController,
                'Waktu Pengantaran',
                readOnly: true,
                validator: (v) => v!.isEmpty ? 'Pilih waktu pengantaran' : null,
                onTap: () => _selectTime(context),
              ),

              const SizedBox(height: 10),

              /// 🌍 Zona waktu
              DropdownButtonFormField<String>(
                value: _zonaWaktu,
                decoration: const InputDecoration(
                    labelText: 'Zona Waktu', border: OutlineInputBorder()),
                items: _zonaList
                    .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    final oldZone = _zonaWaktu;
                    _zonaWaktu = val;
                    // Konversi waktu yang telah dipilih ke zona waktu baru
                    _jamPengantaran =
                        _convertTimeByZone(_jamPengantaran, oldZone, _zonaWaktu); 
                    _waktuPengantaranDisplayController.text =
                        '${_jamPengantaran.hour.toString().padLeft(2, '0')}:${_jamPengantaran.minute.toString().padLeft(2, '0')}';
                  });
                },
              ),

              const SizedBox(height: 10),

              /// 💱 Currency
              DropdownButtonFormField<String>(
                value: _currency,
                decoration: const InputDecoration(
                    labelText: 'Mata Uang', border: OutlineInputBorder()),
                items: _currencyList
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) async {
                  if (val == null) return;
                  setState(() => _currency = val);

                  if (_currency == 'IDR') {
                    setState(() {
                      _kurs = 1.0;
                      _updateTotal();
                    });
                  } else {
                    try {
                      // Asumsi: _apiService.getKurs mengembalikan kurs konversi IDR ke mata uang target
                      double kurs = await _apiService.getKurs(_currency);
                      setState(() {
                        _kurs = kurs;
                        _updateTotal();
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal mengambil kurs $_currency')),
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 20),

              if (_hariPenjemputan != null)
                Card(
                  color: Colors.lightGreen.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✅ Penjemputan Otomatis',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700)),
                        const Divider(height: 10, color: Colors.transparent),
                        Text('Tanggal Penjemputan: ${_formatDateOnly(_hariPenjemputan!)}'),
                        Text('Waktu Penjemputan: ${_jamPenjemputan.hour.toString().padLeft(2, '0')}:${_jamPenjemputan.minute.toString().padLeft(2, '0')}'),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📝 Ringkasan Pemesanan',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor)),
                      const Divider(),
                      Text('Layanan: ${widget.layanan.nama}'),
                      Text('Harga per Malam: ${_formatHarga(widget.layanan.harga)}'),
                      Text(
                          'Jarak ke Hotel: ${widget.distanceInKm?.toStringAsFixed(2) ?? 'N/A'} km'),
                      const SizedBox(height: 10),
                      Text('Total Akhir: ${_formatHarga(_totalHarga)}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _simpanPesanan,
                style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text('Konfirmasi Pemesanan',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}