import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/env_config.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/factories/service_factory.dart';
import 'core/routes/app_router.dart';

// Imports pour l'authentification
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_navigation_bloc.dart';
import 'features/auth/di/auth_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger d'abord les variables d'environnement
  await EnvConfig.load();

  // Puis initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser les services optimisés
  await ServiceFactory.initializeServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Fournisseur BLoC d'authentification
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthInjection.getAuthBloc()..add(const AuthCheckRequested()),
        ),

        // Fournisseur BLoC de navigation d'authentification
        BlocProvider<AuthNavigationBloc>(
          create: (context) => AuthInjection.getAuthNavigationBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Ruche Connectée',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', ''),
        ],
      ),
    );
  }
}
