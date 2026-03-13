import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/currency/currency_bloc.dart';
import '../../blocs/currency/currency_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../../core/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Base currency changed to ${state.baseCurrency}'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            final currencyState = context.watch<CurrencyBloc>().state;
            final symbols = currencyState is CurrencyLoaded
                ? currencyState.symbols.keys.toList()
                : <String>[];

            final currentBase = settingsState is SettingsLoaded
                ? settingsState.baseCurrency
                : settingsState is SettingsSaved
                ? settingsState.baseCurrency
                : 'USD';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(
                    title: 'Currency Settings',
                    icon: Icons.currency_exchange_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Select the base currency for normalisation',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        _BaseCurrencySelector(
                          currentBase: currentBase,
                          symbols: symbols,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  _section(
                        title: 'About',
                        icon: Icons.info_outline_rounded,
                        child: Column(
                          children: [
                            _infoTile('App Version', '1.0.0'),
                            _infoTile('API Provider', 'APILayer ExchangeRates'),
                            _infoTile('Cache Duration', '1 hour'),
                            _infoTile('Min currencies', '35+'),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideY(begin: 0.1),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dividerColor, height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Base Currency Selector ────────────────────────────────────────────────────

class _BaseCurrencySelector extends StatefulWidget {
  final String currentBase;
  final List<String> symbols;

  const _BaseCurrencySelector({
    required this.currentBase,
    required this.symbols,
  });

  @override
  State<_BaseCurrencySelector> createState() => _BaseCurrencySelectorState();
}

class _BaseCurrencySelectorState extends State<_BaseCurrencySelector> {
  late String _selected;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.currentBase;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.symbols
        .where((s) => s.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search currency...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: (v) => setState(() => _q = v),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final code = filtered[i];
              final sel = code == _selected;
              return InkWell(
                onTap: () {
                  setState(() => _selected = code);
                  ctx.read<SettingsBloc>().add(ChangeBaseCurrencyEvent(code));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppTheme.primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          color: sel
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimary,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (sel)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
