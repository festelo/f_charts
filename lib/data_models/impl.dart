import 'base.dart';

class IntDateChartEntity extends ChartEntity<int, DateTime> {
  final IntMeasure abscissa;
  final DateMeasure ordinate;

  IntDateChartEntity(int abscissa, DateTime ordinate)
      : abscissa = IntMeasure(abscissa),
        ordinate = DateMeasure(ordinate);
}

class DateIntChartEntity extends ChartEntity<DateTime, int> {
  final DateMeasure abscissa;
  final IntMeasure ordinate;

  DateIntChartEntity(DateTime abscissa, int ordinate)
      : abscissa = DateMeasure(abscissa),
        ordinate = IntMeasure(ordinate);
}

class IntChartEntity extends ChartEntity<int, int> {
  final IntMeasure abscissa;
  final IntMeasure ordinate;

  IntChartEntity(int abscissa, int ordinate)
      : abscissa = IntMeasure(abscissa),
        ordinate = IntMeasure(ordinate);
}

class DateMeasure extends Measure<DateTime> {
  final DateTime value;
  DateMeasure(this.value);

  @override
  int compareTo(Measure<DateTime> other) {
    return value.compareTo(other.value);
  }

  @override
  double stepValue(DateTime min) {
    return (value.millisecondsSinceEpoch - min.millisecondsSinceEpoch)
        .toDouble();
  }
}

class IntMeasure extends Measure<int> {
  final int value;
  IntMeasure(this.value);

  @override
  int compareTo(Measure<int> other) {
    return value.compareTo(other.value);
  }

  @override
  double stepValue(int min) {
    return (value - min).toDouble();
  }

  @override
  String toString() => value.toString();
}
