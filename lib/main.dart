import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'injection_container.dart';
import 'presentation/blocs/currency/currency_bloc.dart';
import 'presentation/blocs/currency/currency_event.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await initDependencies();
  runApp(const CurrencyXApp());
}

class CurrencyXApp extends StatelessWidget {
  const CurrencyXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrencyBloc>(
          create: (_) =>
              sl<CurrencyBloc>()..add(const LoadInitialDataEvent()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) =>
              sl<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'CurrencyX',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        color: AppTheme.backgroundColor,
        home: const HomePage(),
      ),
    );
  }
}
