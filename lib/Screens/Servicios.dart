import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moviles/screens/detallesservicio.dart';

class Servicios extends StatefulWidget {
  @override
  _ServiciosState createState() => _ServiciosState();
}

class _ServiciosState extends State<Servicios> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  // Función para asignar un color diferente a cada tipo de servicio
  Color getColorForTipoServicio(String tipoServicio) {
    switch (tipoServicio.toLowerCase()) {
      case 'fontanería':
        return Colors.blue;
      case 'electricidad':
        return Colors.orange;
      case 'reparación de electrodomésticos':
        return Colors.green;
      case 'limpieza del hogar':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos los Servicios Publicados'),
        actions: [
          IconButton(
            onPressed: () {
              // Limpia el campo de búsqueda
              _searchController.clear();
            },
            icon: Icon(Icons.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Actualiza la lista al cambiar el texto del campo de búsqueda
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Buscar Servicio',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('servicios')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var servicios = snapshot.data?.docs;

                // Filtra los servicios según el texto de búsqueda
                var filteredServicios = servicios!
                    .where((servicio) =>
                        servicio
                            .data()['tipoServicio']
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()) ||
                        servicio
                            .data()['descripcion']
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: filteredServicios.length,
                  itemBuilder: (context, index) {
                    var servicio = filteredServicios[index].data();
                    // Obtener la lista de imágenes desde el documento
                    List<String> imagene =
                        List<String>.from(servicio['imagenes'] ?? []);

                    return GestureDetector(
                      onTap: () {
                        // Navegar a la página de detalles del servicio
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleServicioPage(
                                tipoServicio: servicio['tipoServicio'],
                                descripcion: servicio['descripcion'],
                                precioAproximado: servicio['precioAproximado'],
                                userName: servicio['userName'],
                                imagenes: imagene,
                                idservicio: servicio['idservicio'],
                                idUsuarioProveedor: servicio['idusuario']),
                          ),
                        );
                      },
                      child: Card(
                        color:
                            getColorForTipoServicio(servicio['tipoServicio']),
                        child: ListTile(
                          title: Text(
                            servicio['tipoServicio'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            servicio['descripcion'],
                            style: TextStyle(color: Colors.white),
                          ),
                          // Puedes agregar más elementos aquí según la estructura de tu documento
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
