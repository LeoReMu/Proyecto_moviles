import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moviles/services/AuthModel.dart';
import 'package:moviles/services/firebase_service.dart';
import 'package:moviles/routes/routes.dart';
import 'package:provider/provider.dart';

class Addservicios extends StatefulWidget {
  @override
  _AddserviciosState createState() => _AddserviciosState();
}

class _AddserviciosState extends State<Addservicios> {
  List<File> _selectedImages = [];
  TextEditingController _direccionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _precioController = TextEditingController();

  final List<String> tiposDeServicio = [
    'Fontanería',
    'Electricidad',
    'Reparación de electrodomésticos',
    'Limpieza del hogar',
  ];
  String? _selectedTipoServicio;

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of<AuthModel>(context, listen: false);
    print('Debug Widget: ${authModel.isLoggedIn}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Servicio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField(
                value: _selectedTipoServicio,
                items: tiposDeServicio.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTipoServicio = value as String?;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Tipo de Servicio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione el tipo de servicio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Precio Aproximado',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el precio aproximado';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la dirección';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildImagePicker(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedTipoServicio != null &&
                      _selectedTipoServicio!.isNotEmpty &&
                      _selectedImages.isNotEmpty) {
                    List<Location>? locations;
                    try {
                      locations = await locationFromAddress(
                        _direccionController.text,
                      );
                    } catch (e) {
                      print('Error obteniendo la ubicación: $e');
                    }

                    if (locations != null && locations.isNotEmpty) {
                      // Utiliza las coordenadas obtenidas
                      Servicio nuevoServicio = Servicio(
                        servId: '',
                        userId: FirebaseService.getUserId(),
                        userName: '',
                        tipoServicio: _selectedTipoServicio!,
                        descripcion: _descripcionController.text,
                        precioAproximado:
                            double.tryParse(_precioController.text) ?? 0.0,
                        latitud: locations[0].latitude,
                        longitud: locations[0].longitude,
                        imagenes: [], // Puedes manejar las imágenes según tu lógica
                      );

                      // Cargar imágenes si están seleccionadas
                      for (File image in _selectedImages) {
                        String imageUrl = await FirebaseService.uploadImage(
                            image, FirebaseService.getUserId());
                        nuevoServicio.imagenes.add(imageUrl);
                      }

                      await FirebaseService.addServicio(nuevoServicio);

                      _selectedTipoServicio = null;
                      _descripcionController.clear();
                      _precioController.clear();
                      _direccionController.clear();
                      _selectedImages.clear();

                      Navigator.pushNamed(context, routes.HOME);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Servicio agregado con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      // No se pudieron obtener coordenadas para la dirección ingresada
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No se pudo obtener la ubicación para la dirección ingresada',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Seleccione al menos una imagen'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Agregar Servicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _pickImage(),
          child: Text('Seleccionar Imagen'),
        ),
        if (_selectedImages.isNotEmpty) SizedBox(height: 16),
        Text('Imágenes seleccionadas:'),
        SizedBox(height: 8),
        Row(
          children: _selectedImages.map((image) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                image,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }
}
