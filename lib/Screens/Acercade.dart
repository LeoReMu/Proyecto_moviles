import 'package:flutter/material.dart';

class AcercaDePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de'),
        centerTitle: true,
      ),
      body: _buildEquipoList(),
    );
  }

  Widget _buildEquipoList() {
    return ListView(
      children: [
        _buildEquipoInfo(),
        SizedBox(height: 20),
        _buildIntegranteItem('Eduardo Leonel Reyes Muñiz', '2077404'),
        _buildIntegranteItem('Maria Félix Flores Grimaldo', '1919543'),
        _buildIntegranteItem('Brenda Nallely Flores Torres', '1849970'),
        _buildIntegranteItem('José Roberto Esparza Reséndiz', '1954475'),
        _buildIntegranteItem('Cesar Eduardo Villareal Garza', '1747253'),
      ],
    );
  }

  Widget _buildEquipoInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[300],
      child: Column(
        children: [
          Text(
            'Equipo 5',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Proyecto de Moviles',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegranteItem(String nombre, String matricula) {
    return ListTile(
      title: Text(nombre),
      subtitle: Text('Matrícula: $matricula'),
    );
  }
}
