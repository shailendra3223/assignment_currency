import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/currency/currency_bloc.dart';
import '../../blocs/currency/currency_event.dart';
import '../../blocs/currency/currency_state.dart';
import '../currencies_list/currencies_list_page.dart';
import '../settings/settings_page.dart';
import '../../widgets/currency_input_card.dart';
import '../../widgets/result_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_widget.dart' as app_error;
import '../../widgets/offline_banner.dart';
import '../../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocBuilder<CurrencyBloc, CurrencyState>(
        builder: (context, state) {
          return Container(
            color: AppTheme.backgroundColor,
            child: CustomScrollView(
              slivers: [
                _appBar(context, state),
                if (state is CurrencyLoaded && state.isOffline)
                  const SliverToBoxAdapter(
                      child: OfflineBanner()
                  ),
                if (state is CurrencyLoading)
                  const SliverFillRemaining(
                      child: LoadingShimmer()
                  ),
                if (state is CurrencyError)
                  SliverFillRemaining(
                    child: app_error.AppErrorWidget(
                      message: state.message,
                      onRetry: () => context.read<CurrencyBloc>().add(
                        const LoadInitialDataEvent(),
                      ),
                    ),
                  ),
                if (state is CurrencyLoaded) ...[
                  _ratesInfo(state),
                  _inputsList(context, state),
                  _addButton(context),
                  if (state.calculatedTotal != null || state.isCalculating)
                    _resultSection(state),
                  _calcButton(context, state),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _appBar(BuildContext context, CurrencyState state) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'CurrencyX',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A2E), AppTheme.backgroundColor],
            ),
          ),
        ),
      ),
      actions: [
        if (state is CurrencyLoaded)
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.textSecondary,
            ),
            onPressed: () =>
                context.read<CurrencyBloc>().add(const RefreshRatesEvent()),
            tooltip: 'Refresh rates',
          ),
        IconButton(
          icon: const Icon(Icons.list_rounded, color: AppTheme.textSecondary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CurrenciesListPage()),
          ),
          tooltip: 'All currencies',
        ),
        IconButton(
          icon: const Icon(
            Icons.settings_rounded,
            color: AppTheme.textSecondary,
          ),
          onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ).then(
                (_) => context.read<CurrencyBloc>().add(
                  const LoadInitialDataEvent(),
                ),
              ),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _ratesInfo(CurrencyLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.currency_exchange_rounded,
                    color: AppTheme.primaryColor,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Base: ${state.baseCurrency}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Updated ${_ago(state.rates.timestamp)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _inputsList(BuildContext context, CurrencyLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((ctx, i) {
          final input = state.inputs[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                CurrencyInputCard(
                      key: ValueKey(input.id),
                      input: input,
                      symbols: state.symbols,
                      showRemoveButton: state.inputs.length > 1,
                      onCurrencyChanged: (code) =>
                          context.read<CurrencyBloc>().add(
                            UpdateCurrencyCodeEvent(
                              inputId: input.id,
                              currencyCode: code,
                            ),
                          ),
                      onAmountChanged: (amt) =>
                          context.read<CurrencyBloc>().add(
                            UpdateAmountEvent(inputId: input.id, amount: amt),
                          ),
                      onRemove: () => context.read<CurrencyBloc>().add(
                        RemoveCurrencyInputEvent(input.id),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (i * 50).ms)
                    .slideY(begin: 0.1, end: 0),
          );
        }, childCount: state.inputs.length),
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: OutlinedButton.icon(
          onPressed: () =>
              context.read<CurrencyBloc>().add(const AddCurrencyInputEvent()),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Add Currency'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultSection(CurrencyLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child:
            ResultCard(
                  total: state.calculatedTotal,
                  baseCurrency: state.baseCurrency,
                  isLoading: state.isCalculating,
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95)),
      ),
    );
  }

  Widget _calcButton(BuildContext context, CurrencyLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: state.isCalculating
                    ? null
                    : () => context.read<CurrencyBloc>().add(
                        const CalculateTotalEvent(),
                      ),
                icon: state.isCalculating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.calculate_rounded, size: 20),
                label: Text(
                  state.isCalculating ? 'Calculating...' : 'Calculate Total',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              onPressed: () =>
                  context.read<CurrencyBloc>().add(const ClearAllInputsEvent()),
              icon: const Icon(Icons.clear_all_rounded),
              style: IconButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.dividerColor),
                padding: const EdgeInsets.all(14),
              ),
              tooltip: 'Clear all',
            ),
          ],
        ),
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
