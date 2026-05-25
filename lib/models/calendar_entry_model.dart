class CalendarEntry {
  final String date; // YYYY-MM-DD string — matches API
  final String? outfitId;
  final String? outfitTitle;
  final String? outfitImageUrl;
  final String? styleTag;
  final String? note;

  CalendarEntry({
    required this.date,
    this.outfitId,
    this.outfitTitle,
    this.outfitImageUrl,
    this.styleTag,
    this.note,
  });

  bool get hasOutfit => outfitId != null;

  // Parse date string to DateTime for display
  DateTime get dateTime {
    final parts = date.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  factory CalendarEntry.fromMap(Map<String, dynamic> map) {
    // Handle both API format (_id, date as string) and local format
    String dateStr = '';
    if (map['date'] is String) {
      dateStr = (map['date'] as String).substring(0, 10); // trim time if ISO
    } else if (map['date'] is DateTime) {
      final d = map['date'] as DateTime;
      dateStr = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
    }
    return CalendarEntry(
      date: dateStr,
      outfitId: map['outfitId'],
      outfitTitle: map['outfitTitle'],
      outfitImageUrl: map['outfitImageUrl'],
      styleTag: map['styleTag'],
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() => {
    'date': date,
    'outfitId': outfitId,
    'outfitTitle': outfitTitle,
    'outfitImageUrl': outfitImageUrl,
    'styleTag': styleTag,
    'note': note,
  };
}
