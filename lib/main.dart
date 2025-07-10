import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/auth_provider.dart';
import 'services/websocket_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/connectivity_listener.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => WebSocketService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: ConnectivityListener(child: const AndarBaharApp()),
    ),
  );
}

class AndarBaharApp extends StatelessWidget {
  const AndarBaharApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trigger auth initialization
    context.read<AuthProvider>();
    return MaterialApp(
      title: 'Andar Bahar - अंदर बाहर',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
      ],
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isInitialized) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return authProvider.isSignedIn
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
