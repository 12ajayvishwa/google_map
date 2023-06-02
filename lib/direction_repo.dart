import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocation_methoda/.env.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/direction_model.dart';

class DirectionRepository {
  static const String _baseUrl =
      "https://maps.googleapis.com/maps/api/directions/json";

  final Dio _dio;

  DirectionRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections(
      {required LatLng origin, required LatLng destination}) async {
    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${origin.latitude},${origin.longitude}',
      'key': googleAPIKey
    });
    print(response.data);

    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return Directions.fromMap(response.data);
  }
}
