import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moviles/Screens/Home_controller.dart';
import 'package:moviles/routes/routes.dart';
import 'package:moviles/services/AuthModel.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of<AuthModel>(context, listen: false);

    return ChangeNotifierProvider<HomeController>(
      create: (_) => HomeController(),
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu),
              );
            },
          ),
        ),
        body: _buildBody(),
        drawer: _buildDrawer(context, authModel),
        floatingActionButton: _buildFAB(context, authModel),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: _buildMap(),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Selector<HomeController, bool>(
      selector: (_, controller) => controller.loading,
      builder: (context, loading, loadingwidget) {
        if (loading) {
          return loadingwidget!;
        }
        return Consumer<HomeController>(
          builder: (_, controller, gpsMenssageWidget) {
            if (!controller.gpsEnabled) {
              return gpsMenssageWidget!;
            }
            print('Marcadores: ${controller.markers.length}');
            return GoogleMap(
              initialCameraPosition: controller.initialCameraposition,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              compassEnabled: false,
              markers: controller.markers,
            );
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Para poder utilizar la aplicación debes habilitar el GPS",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    final controller = context.watch()<HomeController>();
                    controller.turnOnGPS();
                  },
                  child: const Text("Encender GPS"),
                ),
              ],
            ),
          ),
        );
      },
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthModel authModel) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text("Menu"),
          ),
          if (authModel.isLoggedIn) ...[
            ListTile(
              title: const Text('Mi cuenta'),
              onTap: () {
                Navigator.pushNamed(context, routes.MICUENTA);
              },
            ),
            ListTile(
              title: Text('Agregar un servicio'),
              onTap: () {
                Navigator.pushNamed(context, routes.ADDSERV);
              },
            ),
            ListTile(
              title: Text('Mis pedidos'),
              onTap: () {
                Navigator.pushNamed(context, routes.PEDIDOS);
              },
            ),
            ListTile(
              title: Text('Mis pendientes'),
              onTap: () {
                Navigator.pushNamed(context, routes.PENDIENTES);
              },
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () {
                authModel.logout(); // Cierra sesión
                Navigator.pushNamed(context, routes.HOME);
              },
            ),
          ] else ...[
            ListTile(
              title: const Text('Iniciar sesión'),
              onTap: () {
                Navigator.pushNamed(context, routes.INICIARSESION);
              },
            ),
          ],
          ListTile(
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pushNamed(context, routes.ACERCADE);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, AuthModel authModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: FloatingActionButton.extended(
        onPressed: () {
          if (authModel.isLoggedIn) {
            Navigator.pushNamed(context, routes.SERVICIOS);
          } else {
            _showLoginDialog(context);
          }
        },
        label: const Text("Buscar servicios"),
        icon: const Icon(Icons.search),
        backgroundColor: Colors.blue, // Color llamativo
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Iniciar Sesión'),
          content: Text('Para continuar, inicia sesión.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, routes.INICIARSESION);
              },
              child: Text('Iniciar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
