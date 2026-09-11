import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'principal_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool cargando = false;
  bool mostrarPassword = false;

  Future<void> iniciarSesion() async {
    final usuario = usuarioController.text.trim();
    final password = passwordController.text;

    if (usuario.isEmpty || password.isEmpty) {
      mostrarMensaje(
        'Ingresa usuario y contraseña',
        Colors.red,
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final resultado = await authService.login(
        usuario,
        password,
      );

      if (resultado == null) {
        mostrarMensaje(
          'No se encontró el usuario',
          Colors.red,
        );
        return;
      }

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrincipalPage(
            usuario: resultado,
            authService: authService,
          ),
        ),
      );
    } catch (e) {
      mostrarMensaje(
        e.toString().replaceFirst('Exception: ', ''),
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Fondo azul
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),

            child: Container(
              width: 430,
              padding: const EdgeInsets.all(35),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Icono
                  Container(
                    width: 90,
                    height: 90,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Color(0xFF1565C0),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Título
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B7A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo
                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF607DAB),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Usuario
                  TextField(
                    controller: usuarioController,

                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF4169A1),
                      ),

                      filled: true,
                      fillColor: const Color(0xFFF5F9FF),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFFD0DDF0),
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFFD0DDF0),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contraseña
                  TextField(
                    controller: passwordController,
                    obscureText: !mostrarPassword,

                    decoration: InputDecoration(
                      labelText: 'Contraseña',

                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF4169A1),
                      ),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            mostrarPassword = !mostrarPassword;
                          });
                        },

                        icon: Icon(
                          mostrarPassword
                              ? Icons.visibility
                              : Icons.visibility_off,

                          color: const Color(0xFF4169A1),
                        ),
                      ),

                      filled: true,
                      fillColor: const Color(0xFFF5F9FF),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFFD0DDF0),
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFFD0DDF0),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: cargando ? null : iniciarSesion,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,

                        elevation: 3,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      child: cargando
                          ? const SizedBox(
                              width: 25,
                              height: 25,

                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [
                                Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(width: 10),

                                Icon(
                                  Icons.arrow_forward,
                                  size: 22,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Línea
                  Container(
                    height: 1,
                    color: const Color(0xFFE0E7F0),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Ingresa tus datos para acceder',
                    style: TextStyle(
                      color: Color(0xFF78909C),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}