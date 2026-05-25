class OutfitModel {
  final String id;
  final String title;
  final String styleTag;
  final String imageUrl;
  final List<OutfitItem> items;
  final bool isTrending;
  bool isSaved;

  OutfitModel({required this.id, required this.title, required this.styleTag,
      required this.imageUrl, required this.items, this.isTrending = false, this.isSaved = false});

  factory OutfitModel.fromMap(Map<String, dynamic> map) => OutfitModel(
    id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
    title: map['title'] ?? '',
    styleTag: map['styleTag'] ?? 'Casual',
    imageUrl: map['imageUrl'] ?? '',
    isTrending: map['isTrending'] ?? false,
    isSaved: map['isSaved'] ?? false,
    items: (map['items'] as List? ?? []).map((i) => OutfitItem.fromMap(i)).toList(),
  );

  OutfitModel copyWith({String? id, String? title, String? styleTag, String? imageUrl,
      List<OutfitItem>? items, bool? isTrending, bool? isSaved}) {
    return OutfitModel(id: id ?? this.id, title: title ?? this.title, styleTag: styleTag ?? this.styleTag,
        imageUrl: imageUrl ?? this.imageUrl, items: items ?? this.items,
        isTrending: isTrending ?? this.isTrending, isSaved: isSaved ?? this.isSaved);
  }
}

class OutfitItem {
  final String name;
  final String category;
  final String? brand;
  final String? price;

  OutfitItem({required this.name, required this.category, this.brand, this.price});

  factory OutfitItem.fromMap(Map<String, dynamic> map) => OutfitItem(
    name: map['name'] ?? '',
    category: map['category'] ?? '',
    brand: map['brand'],
    price: map['price'],
  );
}
