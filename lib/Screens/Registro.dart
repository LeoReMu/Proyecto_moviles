import 'package:flutter/material.dart';
import 'package:moviles/routes/routes.dart';
import 'package:moviles/services/AuthModel.dart';
import 'package:moviles/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  String _address = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrarse'),
        backgroundColor: Color(0xFF7AC8E6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa tu nombre de usuario.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              TextFormField(
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa tu correo electrónico.';
                  } else if (!isValidEmail(value!)) {
                    return 'Correo electrónico no válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                style: TextStyle(fontSize: 16),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                ),
                onSaved: (value) {
                  _password = value!;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa una contraseña.';
                  } else if (value!.length <= 6) {
                    return 'La contraseña debe tener más de 6 caracteres.';
                  }
                  return null;
                },
              ),
              TextFormField(
                obscureText: true,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                ),
                onSaved: (value) {
                  _confirmPassword = value!;
                },
              ),
              TextFormField(
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Dirección',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa tu dirección.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _address = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final verificationResult =
                        await FirebaseService.isEmailAlreadyInUse(_email);

                    if (verificationResult ==
                        'El correo electrónico ya está en uso') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('El correo electrónico ya está en uso.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (verificationResult == 'Correo no está en uso') {
                      if (_password != _confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Las contraseñas no coinciden.'),
                          backgroundColor: Colors.red,
                        ));
                      } else {
                        await _registerUser();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hubo un error en la verificación.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child:
                    Text('Confirmar registro', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF4CAF50),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, routes.INICIARSESION);
                },
                child: const Text(
                  '¿Ya tienes una cuenta? Iniciar sesión',
                  style: TextStyle(
                    color: Color(0xFF7AC8E6),
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _registerUser() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    try {
      List<Location> locations = await locationFromAddress(_address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        double latitud = location.latitude;
        double longitud = location.longitude;

        User? user = await FirebaseService.registerUser(
          _email,
          _password,
          _username,
          _address,
          latitud,
          longitud,
        );

        if (user != null) {
          await user.updateDisplayName(_username);
          authModel.login();
          Navigator.pushReplacementNamed(context, routes.HOME);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'No se pudo obtener la ubicación para la dirección proporcionada'),
          ),
        );
      }
    } catch (e) {
      print('Error al registrar usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al registrar usuario'),
        ),
      );
    }
  }
}
