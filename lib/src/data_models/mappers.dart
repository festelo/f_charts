import 'chart_data.dart';

abstract class EntityMapper<T> {
  int compare(T a, T b);
  double toDouble(T current);
  T fromDouble(double point);
  String getString(T value);
}

class ChartMapper<TAbscissa, TOrdinate> {
  final EntityMapper<TAbscissa> abscissaMapper;
  final EntityMapper<TOrdinate> ordinateMapper;
  ChartMapper(this.abscissaMapper, this.ordinateMapper);

  T minOfEntities<T>(EntityMapper<T> mapper, Iterable<T> entities) {
    return entities
        .reduce((a, b) => mapper.compare(a, b) < 0 ? a : b);
  }

  T maxOfEntities<T>(EntityMapper<T> mapper, Iterable<T> entities) {
    return entities
        .reduce((a, b) => mapper.compare(a, b) > 0 ? a : b);
  }

  Iterable<TOrdinate> flatOrdinates(ChartData<TAbscissa, TOrdinate> data) {
    return data.series.map((e) => e.entities).expand((e) => e).map((e) => e.ordinate);
  }

  Iterable<TAbscissa> flatAbscissas(ChartData<TAbscissa, TOrdinate> data) {
    return data.series.map((e) => e.entities).expand((e) => e).map((e) => e.abscissa);
  }

  TOrdinate minOrdinate(ChartData<TAbscissa, TOrdinate> data) {
    return minOfEntities(ordinateMapper, flatOrdinates(data));
  }

  TOrdinate maxOrdinate(ChartData<TAbscissa, TOrdinate> data) {
    return maxOfEntities(ordinateMapper, flatOrdinates(data));
  }

  TAbscissa minAbscissa(ChartData<TAbscissa, TOrdinate> data) {
    return minOfEntities(abscissaMapper, flatAbscissas(data));
  }

  TAbscissa maxAbscissa(ChartData<TAbscissa, TOrdinate> data) {
    return maxOfEntities(abscissaMapper, flatAbscissas(data));
  }

  ChartBounds<TAbscissa, TOrdinate> getBounds(ChartData<TAbscissa, TOrdinate> data) {
    return ChartBounds(
      minAbscissa(data),
      maxAbscissa(data),
      minOrdinate(data),
      maxOrdinate(data),
    );
  }
}