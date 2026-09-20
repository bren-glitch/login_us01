class Producto {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;

  Producto({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      description: json['description'],
      category: json['category'],
    );
  }
}