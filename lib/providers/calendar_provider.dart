import 'package:flutter/material.dart';
import '../models/calendar_entry_model.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class CalendarProvider extends ChangeNotifier {
  Map<String, CalendarEntry> _entries = {};
  DateTime _selectedDate = DateTime.now();

  Map<String, CalendarEntry> get entries => _entries;
  DateTime get selectedDate => _selectedDate;

  CalendarEntry? get selectedEntry => _entries[_dateKey(_selectedDate)];

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Future<void> load() async {
    try {
      final data = await ApiService.get(ApiConfig.calendar);
      _entries = {};
      for (final e in (data['entries'] as List)) {
        final entry = CalendarEntry.fromMap(Map<String, dynamic>.from(e));
        if (entry.date.isNotEmpty) _entries[entry.date] = entry;
      }
    } catch (_) {}
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> logOutfit({
    required DateTime date,
    required String outfitId,
    required String outfitTitle,
    required String outfitImageUrl,
    required String styleTag,
    String? note,
  }) async {
    final key = _dateKey(date);
    try {
      final data = await ApiService.post(ApiConfig.calendar, {
        'date': key, 'outfitId': outfitId, 'outfitTitle': outfitTitle,
        'outfitImageUrl': outfitImageUrl, 'styleTag': styleTag,
        if (note != null) 'note': note,
      });
      _entries[key] = CalendarEntry.fromMap(Map<String, dynamic>.from(data['entry']));
    } catch (_) {
      // Optimistic local update
      _entries[key] = CalendarEntry(date: key, outfitId: outfitId,
          outfitTitle: outfitTitle, outfitImageUrl: outfitImageUrl, styleTag: styleTag, note: note);
    }
    notifyListeners();
  }

  Future<void> removeEntry(DateTime date) async {
    final key = _dateKey(date);
    try { await ApiService.delete(ApiConfig.calendarDate(key)); } catch (_) {}
    _entries.remove(key);
    notifyListeners();
  }

  int get totalLoggedDays => _entries.length;

  List<CalendarEntry> entriesForMonth(int year, int month) {
    return _entries.values.where((e) {
      final dt = e.dateTime;
      return dt.year == year && dt.month == month;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  bool hasEntryForDate(DateTime date) => _entries.containsKey(_dateKey(date));
}
