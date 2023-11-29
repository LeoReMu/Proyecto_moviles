import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moviles/services/firebase_service.dart';

class HomeController extends ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;
  Position? _initialposition;
  CameraPosition get initialCameraposition => CameraPosition(
        target: LatLng(25.6834243, -100.2930212),
        //_initialposition!.latitude,
        //_initialposition!.longitude,
        //),
        zoom: 14,
      );

  bool _loading = true;
  bool get loading => _loading;

  late bool _gpsEnabled;
  bool get gpsEnabled => _gpsEnabled;

  StreamSubscription? _gpsSubscription, _positionSubscription;

  HomeController() {
    _init();
    loadServicios();
  }

  Future<void> loadServicios() async {
    try {
      final servicios = await FirebaseService.obtenerServiciosDesdeFirestore();
      print('Servicios cargados: $servicios');

      _markers = servicios.map((mapservicio) {
        return Marker(
          markerId: MarkerId(mapservicio.tipoServicio),
          position: LatLng(mapservicio.latitud, mapservicio.longitud),
          infoWindow: InfoWindow(
            title: 'Servicio: ${mapservicio.tipoServicio}',
          ),
        );
      }).toSet();

      notifyListeners();
    } catch (e) {
      print('Error al cargar servicios: $e');
    }
  }

  Future<void> _init() async {
    _gpsEnabled = await Geolocator.isLocationServiceEnabled();
    _loading = false;
    _gpsSubscription = Geolocator.getServiceStatusStream().listen(
      (status) async {
        _gpsEnabled = status == ServiceStatus.enabled;
        if (_gpsEnabled) {
          _initlocationUpdates();
        }
      },
    );
    await _initlocationUpdates();
  }

  Future<void> _initlocationUpdates() async {
    bool initialized = false;
    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream().listen(
      (position) {
        print("$position");
        if (!initialized) {
          _setInitialPosition(position);
          initialized = true;
          notifyListeners();
        }
        _setInitialPosition(position);
      },
      onError: (e) {
        print("OnError ${e.runtimeType}");
        if (e is LocationServiceDisabledException) {
          _gpsEnabled = false;
          notifyListeners();
        }
      },
    );
  }

  void _setInitialPosition(Position position) {
    if (_gpsEnabled && _initialposition == null) {
      _initialposition = position;
    }
  }

  Future<void> turnOnGPS() => Geolocator.openLocationSettings();

  void onMapCreated(GoogleMapController controller) {}

  void dispose() {
    _positionSubscription?.cancel();
    _gpsSubscription?.cancel();
    super.dispose();
  }
}
