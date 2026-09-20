import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/auth_service.dart';

class DetalleProductoPage extends StatefulWidget {
  final int productoId;
  final AuthService authService;

  const DetalleProductoPage({
    super.key,
    required this.productoId,
    required this.authService,
  });

  @override
  State<DetalleProductoPage> createState() =>
      _DetalleProductoPageState();
}

class _DetalleProductoPageState
    extends State<DetalleProductoPage> {
  Producto? producto;

  bool cargando = true;
  String? error;
  String? rol;

  @override
  void initState() {
    super.initState();
    cargarProducto();
  }

  Future<void> cargarProducto() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final productoObtenido =
          await widget.authService.obtenerProductoPorId(
        widget.productoId,
      );

      final rolObtenido =
          await widget.authService.obtenerRol();

      if (!mounted) {
        return;
      }

      setState(() {
        producto = productoObtenido;
        rol = rolObtenido;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
        error = 'Producto no disponible';
      });

      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
      ),
      body: construirContenido(),
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
        child: Text(
          error!,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      );
    }

    if (producto == null) {
      return const Center(
        child: Text(
          'Producto no disponible',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.network(
              producto!.image,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            producto!.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            '\$${producto!.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            producto!.description,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            producto!.category,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          if (rol == 'Administrador')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Eliminar'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}