import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/auth_service.dart';

class AgregarProductoPage extends StatefulWidget {
  final AuthService authService;

  const AgregarProductoPage({
    super.key,
    required this.authService,
  });

  @override
  State<AgregarProductoPage> createState() =>
      _AgregarProductoPageState();
}

class _AgregarProductoPageState
    extends State<AgregarProductoPage> {
  final formularioKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final precioController = TextEditingController();
  final descripcionController = TextEditingController();
  final imagenController = TextEditingController();
  final categoriaController = TextEditingController();

  bool cargando = false;
  bool verificandoRol = true;
  bool esAdministrador = false;

  @override
  void initState() {
    super.initState();
    verificarRol();
  }

  Future<void> verificarRol() async {
    final rol = await widget.authService.obtenerRol();

    if (!mounted) {
      return;
    }

    if (rol != 'Administrador') {
      Navigator.pop(context);
      return;
    }

    setState(() {
      esAdministrador = true;
      verificandoRol = false;
    });
  }

  Future<void> guardarProducto() async {
    if (!formularioKey.currentState!.validate()) {
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final producto = Producto(
        id: 0,
        title: tituloController.text.trim(),
        price: double.parse(precioController.text.trim()),
        description: descripcionController.text.trim(),
        image: imagenController.text.trim(),
        category: categoriaController.text.trim(),
      );

      final respuesta =
          await widget.authService.crearProducto(producto);

      if (!mounted) {
        return;
      }

      final idNuevo = respuesta['id'];

      tituloController.clear();
      precioController.clear();
      descripcionController.clear();
      imagenController.clear();
      categoriaController.clear();

      setState(() {
        cargando = false;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Producto creado'),
            content: Text(
              'El producto se creó correctamente. '
              'Su nuevo ID es: $idNuevo',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo crear el producto. Intenta nuevamente.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    precioController.dispose();
    descripcionController.dispose();
    imagenController.dispose();
    categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (verificandoRol) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!esAdministrador) {
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formularioKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa el título';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: precioController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa el precio';
                  }

                  final precio = double.tryParse(valor.trim());

                  if (precio == null || precio < 0) {
                    return 'Ingresa un precio válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa la descripción';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: imagenController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa la URL de imagen';
                  }

                  final url = Uri.tryParse(valor.trim());

                  if (url == null ||
                      !url.hasScheme ||
                      (url.scheme != 'http' &&
                          url.scheme != 'https') ||
                      url.host.isEmpty) {
                    return 'Ingresa una URL válida';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa la categoría';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: cargando ? null : guardarProducto,
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text('Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}