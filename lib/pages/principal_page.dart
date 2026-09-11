import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class PrincipalPage extends StatelessWidget {
  final Usuario usuario;
  final AuthService authService;

  const PrincipalPage({
    super.key,
    required this.usuario,
    required this.authService,
  });

  Future<void> cerrarSesion(BuildContext context) async {
    await authService.cerrarSesion();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla principal'),
        actions: [
          IconButton(
            onPressed: () {
              cerrarSesion(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                '¡Inicio de sesión correcto!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'ID: ${usuario.id}',
                style: const TextStyle(fontSize: 18),
              ),

              Text(
                'Usuario: ${usuario.username}',
                style: const TextStyle(fontSize: 18),
              ),

              Text(
                'Nombre: ${usuario.nombre} ${usuario.apellido}',
                style: const TextStyle(fontSize: 18),
              ),

              Text(
                'Rol: ${usuario.rol}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Interfaz de $usuario.rol',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}