import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/auth_service.dart';

class EditarProductoPage extends StatefulWidget {
  final Producto producto;
  final AuthService authService;

  const EditarProductoPage({
    super.key,
    required this.producto,
    required this.authService,
  });

  @override
  State<EditarProductoPage> createState() =>
      _EditarProductoPageState();
}

class _EditarProductoPageState
    extends State<EditarProductoPage> {
  final formularioKey = GlobalKey<FormState>();

  late TextEditingController tituloController;
  late TextEditingController precioController;
  late TextEditingController descripcionController;
  late TextEditingController categoriaController;

  bool cargando = false;
  bool verificandoRol = true;
  bool esAdministrador = false;

  @override
  void initState() {
    super.initState();

    tituloController =
        TextEditingController(text: widget.producto.title);

    precioController =
        TextEditingController(
      text: widget.producto.price.toString(),
    );

    descripcionController =
        TextEditingController(
      text: widget.producto.description,
    );

    categoriaController =
        TextEditingController(
      text: widget.producto.category,
    );

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

  Future<void> guardarCambios() async {
  if (!formularioKey.currentState!.validate()) {
    return;
  }

  setState(() {
    cargando = true;
  });

  try {
    final productoActualizado = Producto(
      id: widget.producto.id,
      title: tituloController.text.trim(),
      price: double.parse(precioController.text.trim()),
      description: descripcionController.text.trim(),
      image: widget.producto.image,
      category: categoriaController.text.trim(),
    );

    await widget.authService.editarProducto(
      productoActualizado,
    );

    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Producto actualizado'),
          content: const Text(
            'Producto actualizado (Simulación)',
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

    if (!mounted) {
      return;
    }

    Navigator.pop(context, productoActualizado);
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
          'No se pudo actualizar el producto.',
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
        title: const Text('Editar producto'),
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
                  if (valor == null ||
                      valor.trim().isEmpty) {
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
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return 'Ingresa el precio';
                  }

                  final precio =
                      double.tryParse(valor.trim());

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
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return 'Ingresa la descripción';
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
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return 'Ingresa la categoría';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: cargando ? null : guardarCambios,
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}