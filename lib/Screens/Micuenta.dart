import 'package:flutter/material.dart';
import 'package:moviles/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class MiCuentaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Cuenta'),
        centerTitle: true,
      ),
      body: _buildDatosUsuario(),
    );
  }

  Widget _buildDatosUsuario() {
    final String userId = FirebaseService.getUserId();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al obtener los datos del usuario'));
        }

        if (!snapshot.hasData) {
          return Center(
              child: Text('No hay datos disponibles para el usuario.'));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserDataItem('Nombre', userData['name']),
              _buildUserDataItem('Email', userData['email']),
              _buildUserDataItem('Ubicación', userData['address']),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showUpdateAddressDialog(context, userId);
                  },
                  child: Text('Actualizar Dirección'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserDataItem(String label, String value) {
    return ListTile(
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  void _showUpdateAddressDialog(BuildContext context, String userId) {
    TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Actualizar Dirección'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ingrese su nueva dirección:'),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'Ejemplo: Calle 123, Ciudad',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _updateAddress(context, userId, addressController.text);
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAddress(
      BuildContext context, String userId, String newAddress) async {
    try {
      List<Location> locations = await locationFromAddress(newAddress);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        double latitud = location.latitude;
        double longitud = location.longitude;

        await FirebaseService.actualizarDireccion(
          userId,
          newAddress,
          latitud,
          longitud,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dirección actualizada con éxito'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'No se pudo obtener la ubicación para la dirección proporcionada'),
          ),
        );
      }
    } catch (e) {
      print('Error al actualizar la dirección: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al actualizar la dirección'),
        ),
      );
    }
  }
}
