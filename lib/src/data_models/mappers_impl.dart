import 'mappers.dart';

class IntMapper extends EntityMapper<int> {
  @override
  int compare(int a, int b) {
    return a.compareTo(b);
  }

  @override
  double toDouble(int v) => v.toDouble();
  
  @override
  int fromDouble(double d) => d.round();

  @override
  String getString(int value) {
    return value.toString();
  }
}

class DateMapper extends EntityMapper<DateTime> {
  @override
  int compare(DateTime a, DateTime b) {
    return a.compareTo(b);
  }

  @override
  double toDouble(DateTime v) => v.millisecondsSinceEpoch.toDouble();
  
  @override
  DateTime fromDouble(double d) => DateTime.fromMillisecondsSinceEpoch(d.round());

  @override
  String getString(DateTime value) {
    return value.toString();
  }
}