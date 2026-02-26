// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HikeAdapter extends TypeAdapter<Hike> {
  @override
  final int typeId = 1;

  @override
  Hike read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hike(
      id: fields[0] as String,
      name: fields[1] as String,
      points: (fields[2] as List).cast<TrackPoint>(),
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime,
      totalDistance: fields[5] as double,
      elevationGain: fields[6] as double,
      elevationLoss: fields[7] as double,
      durationSeconds: fields[8] as int,
      place: fields[9] as String?,
      description: fields[10] as String?,
      tags: (fields[11] as List?)?.cast<String>(),
      imageUrls: (fields[12] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Hike obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.totalDistance)
      ..writeByte(6)
      ..write(obj.elevationGain)
      ..writeByte(7)
      ..write(obj.elevationLoss)
      ..writeByte(8)
      ..write(obj.durationSeconds)
      ..writeByte(9)
      ..write(obj.place)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.imageUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HikeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
