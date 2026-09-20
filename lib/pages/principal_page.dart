import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/producto.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class PrincipalPage extends StatefulWidget {
  final Usuario usuario;
  final AuthService authService;

  const PrincipalPage({
    super.key,
    required this.usuario,
    required this.authService,
  });

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  List<Producto> productos = [];
  List<String> categorias = [];

  bool cargando = true;
  String? error;
  String? categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() {
      cargando = true;
      error = null;
      productos = [];
    });

    try {
      final categoriasObtenidas =
          await widget.authService.obtenerCategorias();

      final productosObtenidos =
          await widget.authService.obtenerProductos();

      if (!mounted) {
        return;
      }

      setState(() {
        categorias = categoriasObtenidas;
        productos = productosObtenidos;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
        error = 'No se pudieron cargar los productos.';
      });
    }
  }

  Future<void> seleccionarCategoria(String categoria) async {
    setState(() {
      categoriaSeleccionada = categoria;
      cargando = true;
      error = null;
      productos = [];
    });

    try {
      final resultado =
          await widget.authService.obtenerProductosPorCategoria(
        categoria,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        productos = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
        error = 'No se pudieron cargar los productos.';
      });
    }
  }

  Future<void> verTodos() async {
    setState(() {
      categoriaSeleccionada = null;
      cargando = true;
      error = null;
      productos = [];
    });

    try {
      final resultado =
          await widget.authService.obtenerProductos();

      if (!mounted) {
        return;
      }

      setState(() {
        productos = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
        error = 'No se pudieron cargar los productos.';
      });
    }
  }

  Future<void> cerrarSesion() async {
    await widget.authService.cerrarSesion();

    if (!mounted) {
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
        title: const Text('Catálogo de productos'),
        actions: [
          IconButton(
            onPressed: categoriaSeleccionada == null
                ? cargarDatos
                : verTodos,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          construirFiltro(),
          Expanded(
            child: construirContenido(),
          ),
        ],
      ),
    );
  }

  Widget construirFiltro() {
    if (categorias.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 55,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        children: [
          ChoiceChip(
            label: const Text('Ver todos'),
            selected: categoriaSeleccionada == null,
            onSelected: (seleccionado) {
              if (seleccionado) {
                verTodos();
              }
            },
          ),
          const SizedBox(width: 8),
          ...categorias.map(
            (categoria) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(categoria),
                  selected: categoriaSeleccionada == categoria,
                  onSelected: (seleccionado) {
                    if (seleccionado) {
                      seleccionarCategoria(categoria);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget construirContenido() {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            Text(
              error!,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: categoriaSeleccionada == null
                  ? cargarDatos
                  : () => seleccionarCategoria(
                        categoriaSeleccionada!,
                      ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (productos.isEmpty) {
      return const Center(
        child: Text(
          'No hay productos disponibles.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    producto.image,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${producto.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}