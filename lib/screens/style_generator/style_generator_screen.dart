import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';

class StyleGeneratorScreen extends StatefulWidget {
  const StyleGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<StyleGeneratorScreen> createState() => _StyleGeneratorScreenState();
}

class _StyleGeneratorScreenState extends State<StyleGeneratorScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isGenerating = false;

  // Quick-pick chips
  String _selectedOccasion = '';
  String _selectedColor = '';
  String _selectedSeason = '';

  static const List<String> _occasions = [
    'Casual', 'Formal', 'Date Night', 'Business', 'Party', 'Beach', 'Gym',
  ];
  static const List<String> _colors = [
    'Neutrals', 'Blues', 'Pinks', 'Greens', 'Blacks', 'Earthy',
  ];
  static const List<String> _seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];

  @override
  void initState() {
    super.initState();
    final name = context.read<AuthProvider>().currentUser?.name.split(' ').first ?? 'there';
    _messages.add(_ChatMessage(
      text: "Hi $name! ✨ I'm your personal StyleMuse AI.\n\nTell me what you need — an occasion, a vibe, a color, or just type anything. You can also tap the quick chips below!",
      isAI: true,
    ));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send({String? override}) async {
    final text = override ?? _inputCtrl.text.trim();
    if (text.isEmpty && _selectedOccasion.isEmpty) return;

    final userText = text.isNotEmpty
        ? text
        : [
            if (_selectedOccasion.isNotEmpty) _selectedOccasion,
            if (_selectedColor.isNotEmpty) _selectedColor,
            if (_selectedSeason.isNotEmpty) _selectedSeason,
          ].join(' · ');

    setState(() {
      _messages.add(_ChatMessage(text: userText, isAI: false));
      _isGenerating = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    // Parse occasion from message
    String occasion = _selectedOccasion;
    if (occasion.isEmpty) {
      for (final o in _occasions) {
        if (text.toLowerCase().contains(o.toLowerCase())) {
          occasion = o;
          break;
        }
      }
      if (occasion.isEmpty) occasion = 'Casual';
    }

    try {
      final result = await _aiService.generateOutfit(
        occasion: occasion,
        colorPreference: _selectedColor.isEmpty ? null : _selectedColor,
        season: _selectedSeason.isEmpty ? null : _selectedSeason,
      );
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: '',
            isAI: true,
            suggestion: result,
          ));
          _isGenerating = false;
          _selectedOccasion = '';
          _selectedColor = '';
          _selectedSeason = '';
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Hmm, I had trouble generating that look. Try again!',
            isAI: true,
          ));
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const LogoWidget(height: 34),
        centerTitle: false,
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {
              _messages.clear();
              final name = context.read<AuthProvider>().currentUser?.name.split(' ').first ?? 'there';
              _messages.add(_ChatMessage(
                text: "Hi $name! ✨ I'm your personal StyleMuse AI.\n\nTell me what you need — an occasion, a vibe, a color, or just type anything. You can also tap the quick chips below!",
                isAI: true,
              ));
            }),
            tooltip: 'New conversation',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Chat messages ──
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _messages.length + (_isGenerating ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length && _isGenerating) {
                  return _TypingIndicator();
                }
                final msg = _messages[i];
                return msg.isAI
                    ? _AIBubble(message: msg)
                    : _UserBubble(text: msg.text);
              },
            ),
          ),

          // ── Quick chips ──
          Container(
            color: isDark ? AppColors.bgDark : AppColors.bgLight,
            child: Column(
              children: [
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Occasion chips
                _ChipRow(
                  label: 'Occasion',
                  chips: _occasions,
                  selected: _selectedOccasion,
                  onSelect: (v) => setState(() =>
                      _selectedOccasion = _selectedOccasion == v ? '' : v),
                ),
                const SizedBox(height: 8),

                // Color chips
                _ChipRow(
                  label: 'Color',
                  chips: _colors,
                  selected: _selectedColor,
                  onSelect: (v) => setState(() =>
                      _selectedColor = _selectedColor == v ? '' : v),
                ),
                const SizedBox(height: 8),

                // Season chips
                _ChipRow(
                  label: 'Season',
                  chips: _seasons,
                  selected: _selectedSeason,
                  onSelect: (v) => setState(() =>
                      _selectedSeason = _selectedSeason == v ? '' : v),
                ),

                const SizedBox(height: 10),
                const Divider(height: 1),

                // Text input bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _inputCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Describe your occasion or vibe…',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                                    filled: false,
                                  ),
                                  maxLines: 1,
                                  onSubmitted: (_) => _send(),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _isGenerating ? null : _send,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: _isGenerating
                                ? primary.withOpacity(0.4)
                                : primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Data
// ──────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isAI;
  final AIOutfitSuggestion? suggestion;
  _ChatMessage({required this.text, required this.isAI, this.suggestion});
}

// ──────────────────────────────────────────────────
// Chat bubbles
// ──────────────────────────────────────────────────
class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }
}

class _AIBubble extends StatelessWidget {
  final _ChatMessage message;
  const _AIBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, size: 14, color: primary),
              ),
              const SizedBox(width: 8),
              Text('StyleMuse AI',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primary,
                      )),
            ],
          ),
          const SizedBox(height: 6),

          if (message.suggestion != null)
            _OutfitSuggestionCard(suggestion: message.suggestion!, isDark: isDark)
          else
            Container(
              margin: const EdgeInsets.only(bottom: 16, right: 60),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
              ),
              child: Text(message.text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5)),
            ),
        ],
      ),
    );
  }
}

class _OutfitSuggestionCard extends StatelessWidget {
  final AIOutfitSuggestion suggestion;
  final bool isDark;

  const _OutfitSuggestionCard({required this.suggestion, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.primaryDark.withOpacity(0.25), AppColors.accentDark.withOpacity(0.1)]
                    : [AppColors.primaryLight.withOpacity(0.12), AppColors.accentLight.withOpacity(0.06)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Text(suggestion.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('AI Curated',
                            style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 4),
                      Text(suggestion.outfitName,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suggestion.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                const SizedBox(height: 14),

                // Color palette
                Row(
                  children: [
                    Icon(Icons.palette_outlined, size: 14, color: primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(suggestion.colorPalette,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              )),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Items
                ...suggestion.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.09),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_categoryIcon(item.category), color: primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                                Text(item.colorHint,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        )),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(item.category,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary)),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 4),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Styling tip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 15, color: primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(suggestion.stylingTip,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Tops': return Icons.dry_cleaning_outlined;
      case 'Bottoms': return Icons.accessibility_new_outlined;
      case 'Dresses': return Icons.woman_outlined;
      case 'Shoes': return Icons.directions_walk_outlined;
      case 'Outerwear': return Icons.layers_outlined;
      case 'Bags': return Icons.shopping_bag_outlined;
      default: return Icons.watch_outlined;
    }
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(opacity: _anim,
                child: Icon(Icons.auto_awesome, size: 14, color: primary)),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Text(
                'Curating your look${['.','..',  '...'][(_ctrl.value * 2.9).floor()]}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: primary, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final String label;
  final List<String> chips;
  final String selected;
  final void Function(String) onSelect;

  const _ChipRow({
    required this.label,
    required this.chips,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Text('$label:',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              itemBuilder: (_, i) {
                final chip = chips[i];
                final sel = selected == chip;
                return GestureDetector(
                  onTap: () => onSelect(chip),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel ? primary : (isDark ? AppColors.cardDark : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: sel ? primary : (isDark ? AppColors.dividerDark : AppColors.dividerLight)),
                    ),
                    child: Text(chip,
                        style: TextStyle(
                          color: sel ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          fontSize: 11,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        )),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
