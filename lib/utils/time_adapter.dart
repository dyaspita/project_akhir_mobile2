// lib/adapters/time_of_day_adapter.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 14; 

  @override
  TimeOfDay read(BinaryReader reader) {
    final totalMinutes = reader.readInt();
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    final totalMinutes = obj.hour * 60 + obj.minute;
    writer.writeInt(totalMinutes);
  }
}