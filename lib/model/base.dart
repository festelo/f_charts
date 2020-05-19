import 'dart:ui';

class ChartData<TAbscissa  extends Measure, TOrdinate extends Measure, TChartEntity extends ChartEntity<TAbscissa, TOrdinate>> {
  final List<ChartSeries<TAbscissa, TOrdinate, TChartEntity>> series;
  const ChartData(this.series);

  ChartEntity<TAbscissa, TOrdinate> minOrdinate() {
    ChartEntity<TAbscissa, TOrdinate> min;
    for (final s in series) {
      final localMin = s.minOrdinate();
      if (min == null) min = localMin;
      else if (localMin.ordinate.compareTo(min.ordinate) < 0)
        min = localMin;
    }
    return min;
  }

  ChartEntity<TAbscissa, TOrdinate> maxOrdinate() {
    ChartEntity<TAbscissa, TOrdinate> max;
    for (final s in series) {
      final localMax = s.maxOrdinate();
      if (max == null) max = localMax;
      else if (localMax.ordinate.compareTo(max.ordinate) > 0)
        max = localMax;
    }
    return max;
  }

  ChartEntity<TAbscissa, TOrdinate> minAbscissa() {
    ChartEntity<TAbscissa, TOrdinate> min;
    for (final s in series) {
      final localMin = s.minAbscissa();
      if (min == null) min = localMin;
      else if (localMin.abscissa.compareTo(min.abscissa) < 0)
        min = localMin;
    }
    return min;
  }

  ChartEntity<TAbscissa, TOrdinate> maxAbscissa() {
    ChartEntity<TAbscissa, TOrdinate> max;
    for (final s in series) {
      final localMax = s.maxAbscissa();
      if (max == null) max = localMax;
      else if (localMax.abscissa.compareTo(max.abscissa) > 0)
        max = localMax;
    }
    return max;
  }
}


class ChartSeries<TAbscissa extends Measure, TOrdinate extends Measure, TEntity extends ChartEntity<TAbscissa, TOrdinate>> {
  final List<TEntity> entities;
  final Color color;
  final String name;

  const ChartSeries({this.entities, this.color, this.name});

  TEntity minOrdinate() {
    return entities.reduce((a, b) => a.ordinate.compareTo(b.ordinate) < 0 ? a : b);
  }

  TEntity maxOrdinate() {
    return entities.reduce((a, b) => a.ordinate.compareTo(b.ordinate) > 0 ? a : b);
  }

  TEntity minAbscissa() {
    return entities.reduce((a, b) => a.abscissa.compareTo(b.abscissa) < 0 ? a : b);
  }

  TEntity maxAbscissa() {
    return entities.reduce((a, b) => a.abscissa.compareTo(b.abscissa) > 0 ? a : b);
  }
}

abstract class ChartEntity<TAbscissa extends Measure, TOrdinate extends Measure> {
  TOrdinate get ordinate;
  TAbscissa get abscissa;
}

abstract class Measure<T> {
  T get value;
  int compareTo(Measure<T> other);
  double stepValue(T min);
}