import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/currency.dart';
import '../../../domain/entities/currency_input.dart';
import '../../../core/theme/app_theme.dart';

class CurrencyInputCard extends StatefulWidget {
  final CurrencyInput input;
  final Map<String, Currency> symbols;
  final bool showRemoveButton;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onRemove;

  const CurrencyInputCard({
    super.key,
    required this.input,
    required this.symbols,
    required this.showRemoveButton,
    required this.onCurrencyChanged,
    required this.onAmountChanged,
    required this.onRemove,
  });

  @override
  State<CurrencyInputCard> createState() => _CurrencyInputCardState();
}

class _CurrencyInputCardState extends State<CurrencyInputCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.input.amount);
  }

  @override
  void didUpdateWidget(CurrencyInputCard old) {
    super.didUpdateWidget(old);
    if (old.input.amount != widget.input.amount &&
        _ctrl.text != widget.input.amount) {
      _ctrl.text = widget.input.amount;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild symbols as List<MapEntry<String, Currency>> with base type
    // so that indexWhere / comparisons never hit CurrencyModel subtype issues.
    final sorted =
    widget.symbols.entries
        .map((e) => MapEntry<String, Currency>(e.key, e.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(sorted),
          const Divider(color: AppTheme.dividerColor, height: 1),
          _amountInput(),
        ],
      ),
    );
  }

  Widget _header(List<MapEntry<String, Currency>> sorted) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CurrencyDropdown(
              selectedCode: widget.input.currencyCode,
              symbols: sorted,
              onChanged: widget.onCurrencyChanged,
            ),
          ),
          if (widget.showRemoveButton)
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline_rounded,
                color: AppTheme.errorColor,
                size: 22,
              ),
              onPressed: widget.onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Remove',
            ),
        ],
      ),
    );
  }

  Widget _amountInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: const TextStyle(
                color: AppTheme.dividerColor,
                fontSize: 24,
              ),
              prefixText: _symbol(widget.input.currencyCode),
              prefixStyle: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppTheme.surfaceColor,
            ),
            onChanged: widget.onAmountChanged,
          ),
        ],
      ),
    );
  }

  String _symbol(String code) {
    const map = {
      'USD': '\$ ',
      'EUR': '€ ',
      'GBP': '£ ',
      'JPY': '¥ ',
      'INR': '₹ ',
    };
    return map[code] ?? '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CurrencyDropdown extends StatelessWidget {
  final String selectedCode;
  final List<MapEntry<String, Currency>> symbols;
  final ValueChanged<String> onChanged;

  const _CurrencyDropdown({
    required this.selectedCode,
    required this.symbols,
    required this.onChanged,
  });

  void _pick(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _PickerSheet(
        selectedCode: selectedCode,
        symbols: symbols,
        onSelected: (code) {
          onChanged(code);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use indexWhere — never firstWhere+orElse which triggers subtype crash
    final idx = symbols.indexWhere((e) => e.key == selectedCode);
    final currency = idx >= 0
        ? symbols[idx].value
        : Currency(code: selectedCode, name: selectedCode);

    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Text(
              selectedCode,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                currency.name,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PickerSheet extends StatefulWidget {
  final String selectedCode;
  final List<MapEntry<String, Currency>> symbols;
  final ValueChanged<String> onSelected;

  const _PickerSheet({
    required this.selectedCode,
    required this.symbols,
    required this.onSelected,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _q = '';

  String _countryCodeForCurrency(String currency) {
    const map = {
      'USD': 'US',
      'EUR': 'EU',
      'GBP': 'GB',
      'JPY': 'JP',
      'INR': 'IN',
      'AUD': 'AU',
      'CAD': 'CA',
      'CHF': 'CH',
      'CNY': 'CN',
      'SEK': 'SE',
      'NZD': 'NZ',
    };
    if (map.containsKey(currency)) return map[currency]!;
    if (currency.length >= 2) return currency.substring(0, 2);
    return currency;
  }

  String _flagUrlForCurrency(String currency) =>
      'https://countryflagsapi.com/png/${_countryCodeForCurrency(currency).toLowerCase()}';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.symbols
        .where(
          (e) =>
      e.key.toLowerCase().contains(_q.toLowerCase()) ||
          e.value.name.toLowerCase().contains(_q.toLowerCase()),
    )
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, sc) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Currency',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search currencies...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: (v) => setState(() => _q = v),
              autofocus: true,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: sc,
              itemCount: filtered.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, i) {
                final e = filtered[i];
                final sel = e.key == widget.selectedCode;
                return InkWell(
                  onTap: () => widget.onSelected(e.key),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.primaryColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: sel
                          ? Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                      )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: sel
                                ? AppTheme.primaryGradient
                                : const LinearGradient(
                              colors: [
                                AppTheme.surfaceColor,
                                AppTheme.cardColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                _flagUrlForCurrency(e.key),
                                width: 22,
                                height: 22,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Center(
                                  child: Text(
                                    e.key.length >= 2 ? e.key.substring(0, 2) : e.key,
                                    style: TextStyle(
                                      color: sel
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                style: TextStyle(
                                  color: sel
                                      ? AppTheme.primaryColor
                                      : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                e.value.name,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (sel)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
