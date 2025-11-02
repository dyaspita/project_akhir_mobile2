// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pemesanan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PesananAdapter extends TypeAdapter<Pesanan> {
  @override
  final int typeId = 2;

  @override
  Pesanan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pesanan(
      idPemesanan: fields[0] as String,
      username: fields[1] as String,
      namaHewan: fields[2] as String,
      namaLayanan: fields[3] as String,
      jumlahHari: fields[4] as int,
      hariPengantaran: fields[5] as DateTime,
      hariPenjemputan: fields[6] as DateTime,
      jamPengantaran: fields[7] as TimeOfDay,
      jamPenjemputan: fields[8] as TimeOfDay,
      currency: fields[9] as String,
      kurs: fields[10] as double?,
      totalHarga: fields[11] as int,
      distanceInKm: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Pesanan obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.idPemesanan)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.namaHewan)
      ..writeByte(3)
      ..write(obj.namaLayanan)
      ..writeByte(4)
      ..write(obj.jumlahHari)
      ..writeByte(5)
      ..write(obj.hariPengantaran)
      ..writeByte(6)
      ..write(obj.hariPenjemputan)
      ..writeByte(7)
      ..write(obj.jamPengantaran)
      ..writeByte(8)
      ..write(obj.jamPenjemputan)
      ..writeByte(9)
      ..write(obj.currency)
      ..writeByte(10)
      ..write(obj.kurs)
      ..writeByte(11)
      ..write(obj.totalHarga)
      ..writeByte(12)
      ..write(obj.distanceInKm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PesananAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
