import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/currency/currency_bloc.dart';
import '../../blocs/currency/currency_state.dart';
import '../../../core/theme/app_theme.dart';

class CurrenciesListPage extends StatefulWidget {
  const CurrenciesListPage({super.key});

  @override
  State<CurrenciesListPage> createState() => _CurrenciesListPageState();
}

class _CurrenciesListPageState extends State<CurrenciesListPage> {
  String _q = '';
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('All Currencies'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<CurrencyBloc, CurrencyState>(
        builder: (context, state) {
          if (state is! CurrencyLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          final filtered = state.symbols.entries
              .where((e) =>
          e.key.toLowerCase().contains(_q) ||
              e.value.name.toLowerCase().contains(_q))
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: 'Search by code or name...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.textSecondary),
                  suffixIcon: _q.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: AppTheme.textSecondary),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => _q = '');
                    },
                  )
                      : null,
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
                onChanged: (v) => setState(() => _q = v.toLowerCase()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('${filtered.length} currencies',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final e = filtered[i];
                  final rate = state.rates.rates[e.key];
                  return _CurrencyListItem(
                    code: e.key,
                    name: e.value.name,
                    rate: rate,
                    baseCurrency: state.baseCurrency,
                    index: i,
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _CurrencyListItem extends StatelessWidget {
  final String code;
  final String name;
  final double? rate;
  final String baseCurrency;
  final int index;

  const _CurrencyListItem({
    required this.code,
    required this.name,
    this.rate,
    required this.baseCurrency,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              code.substring(0, 2),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ),
        title: Text(code,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        subtitle: Text(name,
            style:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        trailing: rate != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(rate!.toStringAsFixed(4),
                style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            Text('per 1 $baseCurrency',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10)),
          ],
        )
            : null,
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms, delay: (index * 20).ms)
        .slideX(begin: 0.05, end: 0);
  }
}
