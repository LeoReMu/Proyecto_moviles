import 'package:flutter/material.dart';
import 'package:moviles/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MisPedidosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pedidos'),
        centerTitle: true,
      ),
      body: _buildPedidosList(),
    );
  }

  Widget _buildPedidosList() {
    final String userId = FirebaseService.getUserId();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('solicitudes')
          .where('usuarioId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error al obtener los pedidos');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No has realizado pedidos.'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var pedido = snapshot.data!.docs[index];
            String estado = pedido['estado'];

            // Configura el color según el estado
            Color color = estado == 'pendiente' ? Colors.grey : Colors.green;

            return ListTile(
              title: Text(pedido['nombreServicio']),
              subtitle: Text('Estado: $estado'),
              tileColor: color, // Establece el color del fondo del ListTile
              onTap: () {
                // Muestra un diálogo de confirmación para todos los elementos
                _showConfirmationDialog(context, pedido.id);
              },
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, String pedidoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Acción'),
          content: Text('¿Desea eliminar este pedido?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _eliminarPedido(pedidoId);
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarPedido(String pedidoId) {
    // Elimina el pedido de la base de datos
    FirebaseFirestore.instance
        .collection('solicitudes')
        .doc(pedidoId)
        .delete()
        .then((_) {
      print('Pedido eliminado correctamente.');
      // Puedes agregar más lógica aquí según sea necesario
    }).catchError((error) {
      print('Error al eliminar el pedido: $error');
    });
  }
}
