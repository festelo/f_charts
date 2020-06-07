import 'package:f_charts/data_models/_.dart';
import 'package:flutter/painting.dart';

typedef PointPressedCallback<T1, T2> = void Function(ChartEntity<T1, T2> entity);
typedef SwipedCallback<T1, T2> = bool Function(AxisDirection direction);