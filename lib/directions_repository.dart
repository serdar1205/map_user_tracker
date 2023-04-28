import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_user_tracker/constants.dart';

import 'directions_model.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?origin="XXX"&destination="YYY"';

  final Dio _dio;
  DirectionsRepository({ Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    required LatLng orign,
    required LatLng desination,
  }) async {
    final response = await _dio.get(_baseUrl, queryParameters: {
      'orign': '${orign.latitude}, ${orign.longitude}',
      'destination': '${desination.latitude}, ${desination.longitude}',
      'key': google_api_key,
    });

    /// check if response is successful
    if(response.statusCode == 200){
      return Directions.fromMap(response.data);
    }
    return null!;
  }
}
