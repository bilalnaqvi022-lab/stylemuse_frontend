class ClosetItemModel {
  final String id;
  final String name;
  final String category;
  final String imagePath;
  final DateTime addedDate;
  final String? brand;
  final String? color;
  final String? notes;
  final int wearCount;

  ClosetItemModel({required this.id, required this.name, required this.category,
      required this.imagePath, required this.addedDate,
      this.brand, this.color, this.notes, this.wearCount = 0});

  static const List<String> categories = [
    'All','Tops','Bottoms','Dresses','Outerwear','Shoes','Accessories','Bags'];

  // From API (MongoDB uses _id)
  factory ClosetItemModel.fromApiMap(Map<String, dynamic> map) => ClosetItemModel(
    id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
    name: map['name'] ?? '',
    category: map['category'] ?? 'Tops',
    imagePath: map['imagePath'] ?? '',
    addedDate: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    brand: map['brand'],
    color: map['color'],
    notes: map['notes'],
    wearCount: map['wearCount'] ?? 0,
  );

  // From local storage
  factory ClosetItemModel.fromMap(Map<String, dynamic> map) => ClosetItemModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    category: map['category'] ?? 'Tops',
    imagePath: map['imagePath'] ?? '',
    addedDate: DateTime.parse(map['addedDate'] ?? DateTime.now().toIso8601String()),
    brand: map['brand'],
    color: map['color'],
    notes: map['notes'],
    wearCount: map['wearCount'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'category': category,
    'imagePath': imagePath, 'addedDate': addedDate.toIso8601String(),
    'brand': brand, 'color': color, 'notes': notes, 'wearCount': wearCount,
  };
}
