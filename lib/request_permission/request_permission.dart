import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moviles/request_permission/request_permission_controller.dart';
import 'package:moviles/routes/routes.dart';
import 'package:permission_handler/permission_handler.dart';


class RequestPermissionpage extends StatefulWidget {
  const RequestPermissionpage({Key? key}) : super(key: key);

  @override
  State<RequestPermissionpage> createState() => _RequestPermissionpageState();
}

class _RequestPermissionpageState extends State<RequestPermissionpage> with WidgetsBindingObserver{
  final _controller = RequestPermissionController(Permission.locationWhenInUse);
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.onStatusChanged.listen(
      (status) {
        switch (status){
          case PermissionStatus.granted:
            goToHome();
            break;
          case PermissionStatus.permanentlyDenied:
          showDialog(
            context: context, 
            builder: (_) =>AlertDialog(
              title: const Text("Info"),
              content: const Text("Tiene que darnos acceso a la ubicacion de forma manual"),
              actions: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text("ir a configuracion"),
                ),
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: const Text("Cancelar"))
              ],
            ),
          );
            break;      
          case PermissionStatus.denied:
            // TODO: Handle this case.
            break;
          case PermissionStatus.restricted:
            // TODO: Handle this case.
            break;
          case PermissionStatus.limited:
            // TODO: Handle this case.
            break;
          case PermissionStatus.provisional:
            // TODO: Handle this case.
            break;
        }
       },
      );
  }

@override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
     final status = await _controller.check();
     if(status == PermissionStatus.granted){
      goToHome();
     }
    }
    
  }
  void goToHome(){
    Navigator.pushReplacementNamed(context, routes.HOME);
  }

  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: ElevatedButton(
            child: const Text("allow"),
            onPressed: (){
              _controller.request();
            },
          ),
        ),
      ),
    );
  }
}