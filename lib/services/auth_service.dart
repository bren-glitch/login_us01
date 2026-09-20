import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import '../models/producto.dart';

class AuthService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Verificar si hay internet
  Future<bool> hayInternet() async {
    final resultado = await Connectivity().checkConnectivity();

    return resultado.any(
      (conexion) => conexion != ConnectivityResult.none,
    );
  }

  // Iniciar sesión
  Future<Usuario?> login(String username, String password) async {
    // Primero revisamos internet
    final conectado = await hayInternet();

    if (!conectado) {
      throw Exception(
        'No hay conexión a internet. Verifica tu conexión.',
      );
    }

    // Consumimos la API
    final respuesta = await http.post(
      Uri.parse('https://fakestoreapi.com/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    // Credenciales incorrectas
    if (respuesta.statusCode == 401 ||
        respuesta.statusCode == 403) {
      throw Exception('Usuario o contraseña inválidos');
    }

    // Otro error
    if (respuesta.statusCode != 200 && 
    respuesta.statusCode != 201) { 
      throw Exception( 'Error al iniciar sesión. Código: ${respuesta.statusCode}', 
      ); 
    }

    // Obtenemos el token
    final datos = jsonDecode(respuesta.body);

    final token = datos['token'];

    // Guardamos el token de forma segura
    await storage.write(
      key: 'token',
      value: token,
    );

    // Descargamos la información del usuario
    final usuarios = await obtenerUsuarios(token);

    Usuario? usuarioEncontrado;

    for (final usuario in usuarios) {
      if (usuario.username == username) {
        usuarioEncontrado = usuario;
        break;
      }
    }

    return usuarioEncontrado;
  }

  // Obtener usuarios de la API
  Future<List<Usuario>> obtenerUsuarios(String token) async {
    final respuesta = await http.get(
      Uri.parse('https://fakestoreapi.com/users'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudo obtener la información del usuario',
      );
    }

    final datos = jsonDecode(respuesta.body);

    List<Usuario> usuarios = [];

    for (final dato in datos) {
      final id = dato['id'];

      usuarios.add(
        Usuario(
          id: id,
          username: dato['username'],
          email: dato['email'],
          nombre: dato['name']['firstname'],
          apellido: dato['name']['lastname'],
          rol: asignarRol(id),
        ),
      );
    }

    return usuarios;
  }

  // Asignar rol según el ID
  String asignarRol(int id) {
    if (id == 1 || id == 2) {
      return 'Administrador';
    }

    if (id == 3) {
      return 'Auditor';
    }

    return 'Cliente';
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await storage.delete(key: 'token');
  }


  Future<List<Producto>> obtenerProductos() async {
    final respuesta = await http.get(
      Uri.parse('https://fakestoreapi.com/products'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar los productos',
      );
    }

    final datos = jsonDecode(respuesta.body);

    List<Producto> productos = [];

    for (final dato in datos) {
      productos.add(
        Producto.fromJson(dato),
      );
    }

    return productos;
  }
  Future<List<String>> obtenerCategorias() async {
  final respuesta = await http.get(
    Uri.parse('https://fakestoreapi.com/products/categories'),
  );

  if (respuesta.statusCode != 200) {
    throw Exception(
      'No se pudieron cargar las categorías',
    );
  }

  final datos = jsonDecode(respuesta.body);

  List<String> categorias = [];

  for (final dato in datos) {
    categorias.add(dato);
  }

  return categorias;
}

Future<List<Producto>> obtenerProductosPorCategoria(
  String categoria,
) async {
  final respuesta = await http.get(
    Uri.parse(
      'https://fakestoreapi.com/products/category/$categoria',
    ),
  );

  if (respuesta.statusCode != 200) {
    throw Exception(
      'No se pudieron cargar los productos de la categoría',
    );
  }

  final datos = jsonDecode(respuesta.body);

  List<Producto> productos = [];

  for (final dato in datos) {
    productos.add(
      Producto.fromJson(dato),
    );
  }

  return productos;
}

}