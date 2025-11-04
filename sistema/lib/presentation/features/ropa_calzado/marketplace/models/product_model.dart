class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final List<String> sizes;
  final List<String> colors;
  final String collection;
  final bool inStock;
  final String category;
  final List<String>? images;
  final double? originalPrice;
  final int? discount;
  final List<String>? tags;
  final double? rating;
  final int? reviewCount;
  final String? brand;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.sizes,
    required this.colors,
    required this.collection,
    required this.inStock,
    required this.category,
    this.images,
    this.originalPrice,
    this.discount,
    this.tags,
    this.rating,
    this.reviewCount,
    this.brand,
  });

  bool get isOnSale => originalPrice != null && originalPrice! > price;

  String get discountText => discount != null ? '$discount% OFF' : '';
}
