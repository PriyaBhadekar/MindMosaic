import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/services/geofence_service.dart';
import '../data/storage/local_storage.dart';

class GeofenceProvider extends ChangeNotifier {

  Future<void> checkCurrentLocation() async {

    try {

      final patientId =
      LocalStorage.getPatientId();

      if (patientId == null) return;

      Position position =
      await Geolocator.getCurrentPosition();

      bool outside =
      await GeofenceService.checkPatientLocation(

        patientId: patientId,

        latitude: position.latitude,

        longitude: position.longitude,
      );

      print(
        'OUTSIDE SAFE ZONE = $outside',
      );

    } catch (e) {

      print(
        'GEOFENCE ERROR: $e',
      );
    }
  }
}