import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

FirebaseFirestore db = FirebaseFirestore.instance;

class Servicio {
  String tipoServicio;
  String descripcion;
  double precioAproximado;
  double latitud;
  double longitud;
  String userId;
  String servId;
  String userName;
  List<String> imagenes;
  Servicio({
    required this.tipoServicio,
    required this.descripcion,
    required this.precioAproximado,
    required this.latitud,
    required this.longitud,
    required this.userId,
    required this.userName,
    required this.imagenes,
    required this.servId,
  });
}

class mapServicio {
  String tipoServicio;
  double latitud;
  double longitud;
  mapServicio({
    required this.tipoServicio,
    required this.latitud,
    required this.longitud,
  });
}

class UserModel {
  final String name;
  final String id;
  final double longitud;
  final double latitud;

  UserModel({
    required this.name,
    required this.id,
    required this.longitud,
    required this.latitud,
  });
}

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static String getUserId() {
    final User? user = _auth.currentUser;
    return user?.uid ?? '';
  }

  static Future<User?> registerUser(String email, String password, String name,
      String address, double longitud, double latitud) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      // Guarda los datos del usuario en Firebase.
      await db.collection('usuarios').doc(user?.uid).set({
        'name': name,
        'email': email,
        'address': address,
        'longitud': longitud,
        'latidud': latitud,
      });

      return user;
    } catch (e) {
      print("Error al registrar usuario: $e");
      return null;
    }
  }

  static Future<String> isEmailAlreadyInUse(String email) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password:
            'password', // Puedes usar una contraseña temporal ya que no la necesitas para esta verificación.
      );

      // Si el registro se completó correctamente, el correo no está en uso.
      await userCredential.user
          ?.delete(); // Elimina el usuario temporal creado.

      return 'Correo no está en uso';
    } catch (error) {
      if (error is FirebaseAuthException &&
          error.code == 'email-already-in-use') {
        // El correo electrónico ya está en uso.
        return 'El correo electrónico ya está en uso';
      }
      return 'Hubo un error en la verificación';
    }
  }

  static Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }

  static Future<void> addServicio(Servicio servicio) async {
    try {
      final userDoc =
          await db.collection('usuarios').doc(servicio.userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      final DocumentReference servicioref =
          await db.collection('servicios').add({
        'idusuario': servicio.userId,
        'tipoServicio': servicio.tipoServicio,
        'descripcion': servicio.descripcion,
        'precioAproximado': servicio.precioAproximado,
        'latitud': servicio.latitud,
        'longitud': servicio.longitud,
        'userName': userData['name'],
        'imagenes': servicio.imagenes,
      });
      await servicioref.update({'idservicio': servicioref.id});
    } catch (e) {
      print("Error al agregar servicio: $e");
    }
  }

  static Future<String> uploadImage(File imageFile, String userId) async {
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(userId)
          .child('$imageName.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error al cargar la imagen: $e");
      return '';
    }
  }

  static Future<void> addSolicitud(String usuarioId, String servicioId,
      String usservId, String nomServicio) async {
    try {
      await db.collection('solicitudes').add({
        'idUsuarioProveedor': usservId,
        'usuarioId': usuarioId,
        'servicioId': servicioId,
        'nombreServicio': nomServicio,
        'estado': 'pendiente', // Puedes establecer el estado inicial aquí
      });
    } catch (e) {
      print("Error al agregar solicitud: $e");
    }
  }

  static Future<List<mapServicio>> obtenerServiciosDesdeFirestore() async {
    try {
      QuerySnapshot serviciosSnapshot =
          await FirebaseFirestore.instance.collection('servicios').get();

      List<mapServicio> servicios = serviciosSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return mapServicio(
          tipoServicio: data['tipoServicio'],
          latitud: data['latitud'] ?? 0.0,
          longitud: data['longitud'] ?? 0.0,
        );
      }).toList();

      return servicios;
    } catch (e) {
      print('Error al obtener servicios desde Firestore: $e');
      return [];
    }
  }

  static Future<void> actualizarDireccion(
    String userId,
    String newAddress,
    double newLatitud,
    double newLongitud,
  ) async {
    try {
      await db.collection('usuarios').doc(userId).update({
        'address': newAddress,
        'latitud': newLatitud,
        'longitud': newLongitud,
      });

      print('Dirección, latitud y longitud actualizadas correctamente.');
    } catch (e) {
      print('Error al actualizar la dirección, latitud y longitud: $e');
      throw e; // Puedes manejar el error según tus necesidades
    }
  }

  static Future<Map<String, double>?> getLatLongById(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await db.collection('usuarios').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        if (userData.containsKey('latitud') &&
            userData.containsKey('longitud')) {
          double latitud = userData['latitud'] as double;
          double longitud = userData['longitud'] as double;

          return {'latitud': latitud, 'longitud': longitud};
        } else {
          print(
              'Los campos "latitud" y/o "longitud" no están presentes en el documento del usuario con ID: $userId');
          return null;
        }
      } else {
        print('No se encontró el usuario con ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error al obtener la latitud y longitud desde Firestore: $e');
      return null;
    }
  }
}
