import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'pemesanan_model.g.dart';

@HiveType(typeId: 2)
class Pesanan extends HiveObject {
  @HiveField(0)
  String idPemesanan;

  @HiveField(1)
  String username;

  @HiveField(2)
  String namaHewan;

  @HiveField(3)
  String namaLayanan;

  @HiveField(4)
  int jumlahHari;

  @HiveField(5)
  DateTime hariPengantaran;

  @HiveField(6)
  DateTime hariPenjemputan;

  @HiveField(7)
  TimeOfDay jamPengantaran;

  @HiveField(8)
  TimeOfDay jamPenjemputan;

  @HiveField(9)
  String currency;

  @HiveField(10)
  double? kurs;

  @HiveField(11)
  int totalHarga;

  @HiveField(12)
  double distanceInKm;

  Pesanan({
    required this.idPemesanan,
    required this.username,
    required this.namaHewan,
    required this.namaLayanan,
    required this.jumlahHari,
    required this.hariPengantaran,
    required this.hariPenjemputan,
    required this.jamPengantaran,
    required this.jamPenjemputan,
    required this.currency,
    required this.kurs,
    required this.totalHarga,
    required this.distanceInKm,
  });
}
