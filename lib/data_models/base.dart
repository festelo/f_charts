import 'dart:ui';

class ChartData<TAbscissa, TOrdinate,
    TChartEntity extends ChartEntity<Measure<TAbscissa>, Measure<TOrdinate>>> {
  final List<ChartSeries<TAbscissa, TOrdinate, TChartEntity>> series;
  const ChartData(this.series);

  TChartEntity minOrdinateEntity() {
    TChartEntity min;
    for (final s in series) {
      final localMin = s.minOrdinate();
      if (min == null)
        min = localMin;
      else if (localMin.ordinate.compareTo(min.ordinate) < 0) min = localMin;
    }
    return min;
  }

  TChartEntity maxOrdinateEntity() {
    TChartEntity max;
    for (final s in series) {
      final localMax = s.maxOrdinate();
      if (max == null)
        max = localMax;
      else if (localMax.ordinate.compareTo(max.ordinate) > 0) max = localMax;
    }
    return max;
  }

  TChartEntity minAbscissaEntity() {
    TChartEntity min;
    for (final s in series) {
      final localMin = s.minAbscissa();
      if (min == null)
        min = localMin;
      else if (localMin.abscissa.compareTo(min.abscissa) < 0) min = localMin;
    }
    return min;
  }

  TChartEntity maxAbscissaEntity() {
    TChartEntity max;
    for (final s in series) {
      final localMax = s.maxAbscissa();
      if (max == null)
        max = localMax;
      else if (localMax.abscissa.compareTo(max.abscissa) > 0) max = localMax;
    }
    return max;
  }

  ChartBounds<TAbscissa, TOrdinate> getBounds() {
    return ChartBounds(
        minAbscissaEntity().abscissa,
        maxAbscissaEntity().abscissa,
        minOrdinateEntity().ordinate,
        maxOrdinateEntity().ordinate);
  }
}

class ChartSeries<TAbscissa, TOrdinate,
    TEntity extends ChartEntity<Measure<TAbscissa>, Measure<TOrdinate>>> {
  final List<TEntity> entities;
  final Color color;
  final String name;

  const ChartSeries({this.entities, this.color, this.name});

  TEntity minOrdinate() {
    return entities
        .reduce((a, b) => a.ordinate.compareTo(b.ordinate) < 0 ? a : b);
  }

  TEntity maxOrdinate() {
    return entities
        .reduce((a, b) => a.ordinate.compareTo(b.ordinate) > 0 ? a : b);
  }

  TEntity minAbscissa() {
    return entities
        .reduce((a, b) => a.abscissa.compareTo(b.abscissa) < 0 ? a : b);
  }

  TEntity maxAbscissa() {
    return entities
        .reduce((a, b) => a.abscissa.compareTo(b.abscissa) > 0 ? a : b);
  }
}

class ChartBounds<TAbscissa, TOrdinate> {
  final Measure<TAbscissa> minAbscissa;
  final Measure<TAbscissa> maxAbscissa;
  final Measure<TOrdinate> minOrdinate;
  final Measure<TOrdinate> maxOrdinate;

  ChartBounds(
      this.minAbscissa, this.maxAbscissa, this.minOrdinate, this.maxOrdinate);
}

abstract class ChartEntity<TAbscissa extends Measure,
    TOrdinate extends Measure> {
  TOrdinate get ordinate;
  TAbscissa get abscissa;
}

abstract class Measure<T> {
  T get value;
  int compareTo(Measure<T> other);
  double stepValue(T min);
}
