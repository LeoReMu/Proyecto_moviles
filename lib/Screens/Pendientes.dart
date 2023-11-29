import 'package:flutter/material.dart';
import 'package:moviles/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moviles/services/api.dart';
import 'package:geolocator/geolocator.dart';

class MisPendientesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pendientes'),
        centerTitle: true,
      ),
      body: _buildPendientesList(),
    );
  }

  Widget _buildPendientesList() {
    final String userId = FirebaseService.getUserId();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('solicitudes')
          .where('idUsuarioProveedor', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error al obtener las solicitudes');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No hay solicitudes pendientes para tus servicios.'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var solicitud = snapshot.data!.docs[index];

            // Obtener el color dinámicamente según el estado
            Color estadoColor = _getColorForEstado(solicitud['estado']);

            return ListTile(
              title: Text(solicitud['nombreServicio']),
              subtitle: Text('Estado: ${solicitud['estado']}'),
              tileColor: estadoColor, // Asignar color según el estado
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteDialog(context, solicitud.id);
                    },
                  ),
                  if (solicitud['estado'] == 'aceptado')
                    IconButton(
                      icon: Icon(Icons.directions),
                      onPressed: () {
                        _startRoute(context, solicitud);
                      },
                    ),
                ],
              ),
              onTap: () {
                _showAcceptDialog(context, solicitud.id);
              },
            );
          },
        );
      },
    );
  }

  Color _getColorForEstado(String estado) {
    // Asignar colores según el estado
    switch (estado) {
      case 'pendiente':
        return Colors.grey;
      case 'aceptado':
        return Colors.green;
      default:
        return Colors
            .white; // Puedes ajustar el color predeterminado según tus necesidades
    }
  }

  void _showAcceptDialog(BuildContext context, String solicitudId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aceptar Solicitud'),
          content: Text('¿Está seguro de que desea aceptar esta solicitud?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _acceptSolicitud(solicitudId);
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String solicitudId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Solicitud'),
          content: Text('¿Está seguro de que desea eliminar esta solicitud?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteSolicitud(solicitudId);
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _acceptSolicitud(String solicitudId) {
    // Actualiza el estado de la solicitud a "aceptado" en Firestore
    FirebaseFirestore.instance
        .collection('solicitudes')
        .doc(solicitudId)
        .update({'estado': 'aceptado'}).then((_) {
      print('Solicitud aceptada correctamente.');
      // Puedes agregar más lógica aquí según sea necesario
    }).catchError((error) {
      print('Error al aceptar la solicitud: $error');
    });
  }

  void _deleteSolicitud(String solicitudId) {
    // Elimina la solicitud de Firestore
    FirebaseFirestore.instance
        .collection('solicitudes')
        .doc(solicitudId)
        .delete()
        .then((_) {
      print('Solicitud eliminada correctamente.');
      // Puedes agregar más lógica aquí según sea necesario
    }).catchError((error) {
      print('Error al eliminar la solicitud: $error');
    });
  }
}

Future<void> _startRoute(BuildContext context, dynamic solicitud) async {
  try {
    Map<String, double>? latLong =
        await FirebaseService.getLatLongById(solicitud['usuarioId']);

    if (latLong != null &&
        latLong.containsKey('latitud') &&
        latLong.containsKey('longitud')) {
      double destinationLat = latLong['latitud']!;
      double destinationLng = latLong['longitud']!;

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        double originLat = position.latitude;
        double originLng = position.longitude;

        print('Latitud de origen: $originLat, Longitud de origen: $originLng');
        print(
            'Latitud de destino: $destinationLat, Longitud de destino: $destinationLng');

        final directionsData = await GoogleMapsApi.getDirections(
          originLat: originLat,
          originLng: originLng,
          destinationLat: destinationLat,
          destinationLng: destinationLng,
        );

        // Puedes analizar directionsData y realizar acciones según tus necesidades
        print('Información de la ruta: $directionsData');
      } catch (e) {
        print('Error al obtener la ubicación actual: $e');
      }
    } else {
      print(
          'No se pudo obtener la latitud y longitud del usuario con ID ${solicitud['usuarioId']}');
    }
  } catch (e) {
    print('Error al obtener la latitud y longitud desde Firestore: $e');
  }
}
