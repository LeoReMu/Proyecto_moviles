import 'package:flutter/widgets.dart';
import 'package:moviles/Screens/Acercade.dart';
import 'package:moviles/Screens/Addservicios.dart';
import 'package:moviles/Screens/Inicio_sesion.dart';
import 'package:moviles/Screens/Micuenta.dart';
import 'package:moviles/Screens/Pedidos.dart';
import 'package:moviles/Screens/Pendientes.dart';
import 'package:moviles/Screens/Registro.dart';
import 'package:moviles/Screens/Servicios.dart';
import 'package:moviles/Splash/Splash.dart';
import 'package:moviles/request_permission/request_permission.dart';
import 'package:moviles/routes/routes.dart';
import 'package:moviles/Screens/Home_screen.dart';

Map<String, Widget Function(BuildContext)> appRoutes() {
  return {
    routes.SPLASH: (_) => const SplashPage(),
    routes.PERMISSIONS: (_) => const RequestPermissionpage(),
    routes.HOME: (_) => MapScreen(),
    routes.INICIARSESION: (_) => LoginWidget(),
    routes.REGISTRARSE: (_) => RegisterScreen(),
    routes.SERVICIOS: (_) => Servicios(),
    routes.ADDSERV: (_) => Addservicios(),
    routes.MICUENTA: (_) => MiCuentaPage(),
    routes.PENDIENTES: (_) => MisPendientesPage(),
    routes.PEDIDOS: (_) => MisPedidosPage(),
    routes.ACERCADE: (_) => AcercaDePage(),
  };
}
