// ignore_for_file: deprecated_member_use, prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, use_super_parameters, unused_local_variable

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/outfit_model.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/closet_provider.dart';
import '../../services/outfit_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';

class StyleCalendarScreen extends StatefulWidget {
  const StyleCalendarScreen({Key? key}) : super(key: key);

  @override
  State<StyleCalendarScreen> createState() => _StyleCalendarScreenState();
}

class _StyleCalendarScreenState extends State<StyleCalendarScreen> {
  final OutfitService _service = OutfitService();
  List<OutfitModel> _outfits = [];
  late DateTime _focusedMonth;
  late ScrollController _dayScrollCtrl;

  static const List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _dayScrollCtrl = ScrollController();
    context.read<CalendarProvider>().load();
    _loadOutfits();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  Future<void> _loadOutfits() async {
    final list = await _service.getOutfits();
    if (mounted) setState(() => _outfits = list);
  }

  void _scrollToToday() {
    final today = DateTime.now();
    if (_focusedMonth.month == today.month && _focusedMonth.year == today.year) {
      final offset = (today.day - 1) * 72.0;
      if (_dayScrollCtrl.hasClients) {
        _dayScrollCtrl.animateTo(
          offset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _dayScrollCtrl.dispose();
    super.dispose();
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(last.day, (i) => DateTime(month.year, month.month, i + 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final calendar = context.watch<CalendarProvider>();
    final days = _daysInMonth(_focusedMonth);
    final today = DateTime.now();
    final selectedEntry = calendar.selectedEntry;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
              child: Row(
                children: [
                  const LogoWidget(height: 32),
                  const Spacer(),
                  Text(
                    '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                    }),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                    }),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Style Calendar',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                '${calendar.totalLoggedDays} outfits logged',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            // ── Weekday headers ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weekDays
                    .map((d) => SizedBox(
                          width: 32,
                          child: Text(d,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: d == 'Sat' || d == 'Sun'
                                        ? primary.withOpacity(0.5)
                                        : null,
                                  )),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 10),

            // ── Horizontal day strip ──
            SizedBox(
              height: 86,
              child: ListView.builder(
                controller: _dayScrollCtrl,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: days.length,
                itemBuilder: (_, i) {
                  final day = days[i];
                  final isToday = day.year == today.year &&
                      day.month == today.month &&
                      day.day == today.day;
                  final isSelected =
                      calendar.selectedDate.year == day.year &&
                      calendar.selectedDate.month == day.month &&
                      calendar.selectedDate.day == day.day;
                  final hasOutfit = calendar.hasEntryForDate(day);
                  final entry = calendar.entries[
                      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}'];

                  return GestureDetector(
                    onTap: () => calendar.selectDate(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary
                            : (isDark ? AppColors.cardDark : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isToday && !isSelected
                              ? primary
                              : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                          width: isToday && !isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekDays[(day.weekday - 1) % 7],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white70 : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Outfit thumbnail or number
                          if (hasOutfit && entry?.outfitImageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 32, height: 32,
                                child: CachedNetworkImage(
                                  imageUrl: entry!.outfitImageUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => _DayNumber(day: day, isSelected: isSelected),
                                ),
                              ),
                            )
                          else
                            _DayNumber(day: day, isSelected: isSelected),
                          const SizedBox(height: 4),
                          // Dot indicator
                          Container(
                            width: 5, height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasOutfit
                                  ? (isSelected ? Colors.white : primary)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Selected day detail ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: selectedEntry != null && selectedEntry.hasOutfit
                    ? _LoggedDayCard(
                        entry: selectedEntry,
                        onRemove: () => calendar.removeEntry(calendar.selectedDate),
                      )
                    : _EmptyDayCard(
                        date: calendar.selectedDate,
                        outfits: _outfits,
                        onLog: (outfit) => calendar.logOutfit(
                          date: calendar.selectedDate,
                          outfitId: outfit.id,
                          outfitTitle: outfit.title,
                          outfitImageUrl: outfit.imageUrl,
                          styleTag: outfit.styleTag,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Monthly outfit grid ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('This Month', style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(
              height: 90,
              child: () {
                final monthEntries = calendar.entriesForMonth(
                    _focusedMonth.year, _focusedMonth.month);
                if (monthEntries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('No outfits logged this month yet',
                        style: Theme.of(context).textTheme.bodyMedium),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: monthEntries.length,
                  itemBuilder: (_, i) {
                    final e = monthEntries[i];
                    return GestureDetector(
                      onTap: () => calendar.selectDate(e.date as DateTime),
                      child: Container(
                        width: 68, height: 80,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(fit: StackFit.expand, children: [
                            e.outfitImageUrl != null
                                ? CachedNetworkImage(imageUrl: e.outfitImageUrl!, fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                        child: Icon(Icons.checkroom_outlined, color: primary.withOpacity(0.4))))
                                : Container(color: isDark ? AppColors.cardDark : AppColors.cardLight),
                            Positioned(bottom: 0, left: 0, right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.45),
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  '${e.date.day}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    );
                  },
                );
              }(),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

extension on String {
  get day => null;
}

class _DayNumber extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  const _DayNumber({required this.day, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${day.day}',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _LoggedDayCard extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onRemove;
  const _LoggedDayCard({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Image
          if (entry.outfitImageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: entry.outfitImageUrl,
                width: 110, height: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(width: 110, color: primary.withOpacity(0.1),
                    child: Icon(Icons.checkroom_outlined, color: primary)),
              ),
            ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(entry.styleTag ?? '',
                        style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  Text(entry.outfitTitle ?? 'Outfit',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.date.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][entry.date.month - 1]} ${entry.date.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onRemove,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline, size: 14, color: AppColors.errorColor),
                        const SizedBox(width: 4),
                        Text('Remove', style: TextStyle(color: AppColors.errorColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDayCard extends StatelessWidget {
  final DateTime date;
  final List<OutfitModel> outfits;
  final void Function(OutfitModel) onLog;

  const _EmptyDayCard({
    required this.date,
    required this.outfits,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom_outlined, size: 42, color: primary.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            isToday ? "What are you wearing today?" : "No outfit logged",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            isToday ? "Log your look for the day" : "Log an outfit for this day",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: outfits.isEmpty
                ? null
                : () => _showOutfitPicker(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Log Outfit'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _showOutfitPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        builder: (_, ctrl) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primary = Theme.of(context).colorScheme.primary;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Pick an Outfit', style: Theme.of(context).textTheme.headlineSmall),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: outfits.length,
                    itemBuilder: (_, i) {
                      final o = outfits[i];
                      return GestureDetector(
                        onTap: () { Navigator.pop(context); onLog(o); },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.bgLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(imageUrl: o.imageUrl,
                                  width: 50, height: 50, fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(width: 50, height: 50,
                                      color: primary.withOpacity(0.1),
                                      child: Icon(Icons.checkroom_outlined, color: primary))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(o.title, style: Theme.of(context).textTheme.titleSmall),
                              Text(o.styleTag, style: Theme.of(context).textTheme.bodySmall),
                            ])),
                            Icon(Icons.chevron_right, color: primary.withOpacity(0.5)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
