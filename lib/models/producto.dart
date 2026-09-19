
class Producto {
  final int id;
  final String title;
  final double price;
  final String image;

  Producto({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
    );
  }
}

