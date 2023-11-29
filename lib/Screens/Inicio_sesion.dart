import 'package:flutter/material.dart';
import 'package:moviles/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moviles/services/AuthModel.dart';
import 'package:provider/provider.dart';

Color primario = const Color(0xFF7AC8E6);
Color secundario = const Color(0xFF4CAF50);
TextStyle txtprin = TextStyle(fontSize: 16);

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorText = ''; // Variable para almacenar el mensaje de error

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        backgroundColor: primario,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                style: txtprin,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                style: txtprin,
                obscureText: true, // Oculta la contraseña
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text(
                _errorText, // Muestra el mensaje de error
                style: TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;

                  try {
                    final UserCredential userCredential =
                        await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (userCredential.user != null) {
                      // Inicio de sesión exitoso, puedes navegar a la siguiente pantalla.
                      authModel.login();
                      Navigator.pushNamed(context, routes.HOME);
                    } else {
                      // El usuario no se autenticó correctamente, muestra un mensaje de error.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Usuario o contraseña incorrectos.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    String errorMessage = 'Usuario o contraseña incorrectos.';
                    print('$e');

                    if (e is FirebaseAuthException) {
                      switch (e.code) {
                        case 'user-not-found':
                          errorMessage =
                              'Usuario no encontrado. Verifica el correo electrónico.';
                          break;
                        case 'wrong-password':
                          errorMessage =
                              'Contraseña incorrecta. Inténtalo de nuevo.';
                          break;
                        // Otros casos de error de autenticación específicos
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Iniciar Sesión', style: txtprin),
                style: ElevatedButton.styleFrom(
                  primary: secundario,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegar a la pantalla de recuperación de contraseña
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                  //);
                },
                child: Text('¿Olvidaste tu contraseña?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, routes.REGISTRARSE);
                },
                child: Text('¿Aun no tienes cuenta? Registrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
