import 'package:flutter/material.dart';

class VesselOverviewPage extends StatelessWidget {
  const VesselOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BayStream'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Cargar archivo BAPLIE',
            onPressed: () {
              // TODO: Implementar carga de archivo
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_boat,
              size: 100,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 24),
            Text(
              'BayStream',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gestión de Carga Marítima',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Cargue un archivo BAPLIE para comenzar',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
