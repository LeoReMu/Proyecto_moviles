import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:moviles/services/firebase_service.dart';

class DetalleServicioPage extends StatelessWidget {
  final String tipoServicio;
  final String descripcion;
  final double precioAproximado;
  final String userName;
  final List<String> imagenes;
  final String idservicio;
  final String idUsuarioProveedor;

  DetalleServicioPage({
    required this.tipoServicio,
    required this.descripcion,
    required this.precioAproximado,
    required this.userName,
    required this.imagenes,
    required this.idservicio,
    required this.idUsuarioProveedor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Servicio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuario: $userName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            _buildDetailItem('Tipo de Servicio', tipoServicio),
            _buildDetailItem('Descripción', descripcion),
            _buildDetailItem(
                'Precio Aproximado', '\$${precioAproximado.toString()}'),
            SizedBox(height: 30),
            Text(
              'Imágenes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            _buildImageSlider(imagenes),
            SizedBox(height: 60),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                child: Text('Solicitar Servicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildImageSlider(List<String> imagenes) {
    return CarouselSlider.builder(
      itemCount: imagenes.length,
      options: CarouselOptions(
        height: 100,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        enlargeCenterPage: false,
        enableInfiniteScroll: false,
        scrollDirection: Axis.horizontal,
      ),
      itemBuilder: (context, index, realIndex) {
        return GestureDetector(
          onTap: () {
            _showImageDialog(context, imagenes, index);
          },
          child: Image.network(
            imagenes[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  void _showImageDialog(
      BuildContext context, List<String> imagenes, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            children: [
              Expanded(
                child: CarouselSlider.builder(
                  itemCount: imagenes.length,
                  options: CarouselOptions(
                    height: double.infinity,
                    aspectRatio: 1.0,
                    viewportFraction: 1.0,
                    initialPage: index,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return Image.network(
                      imagenes[index],
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Solicitud'),
          content: Text('¿Está seguro de que desea solicitar este servicio?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String usuarioId = FirebaseService.getUserId();
                String servicioId = idservicio;
                String usservId = idUsuarioProveedor;
                String nombreServicio = tipoServicio;

                await FirebaseService.addSolicitud(
                    usuarioId, servicioId, usservId, nombreServicio);

                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
