import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:chronicle/services/api_service.dart';
import 'package:chronicle/services/user_service.dart';
import 'package:chronicle/models/auth_response.dart';
import 'package:chronicle/screens/dashboard_screen.dart';
import 'package:chronicle/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode? _themeMode;
  bool _initializing = true;
  LoginResponse? _loginData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (ApiService.token != null && ApiService.currentUserId != null) {
      try {
        final user = await UserService.getUserProfile(
          ApiService.currentUserId!,
        );
        setState(() {
          _loginData = user;
          _initializing = false;
        });
      } catch (e) {
        setState(() {
          _initializing = false;
        });
      }
    } else {
      setState(() {
        _initializing = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_themeMode == null) {
      final Brightness systemBrightness = MediaQuery.of(
        context,
      ).platformBrightness;
      _themeMode = systemBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      setState(() {});
    }
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chronicle',
      themeMode: _themeMode ?? ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(toolbarHeight: 48, centerTitle: true),
        navigationBarTheme: NavigationBarThemeData(
          height: 60,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.deepPurple.withValues(alpha: 0.1),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(toolbarHeight: 48, centerTitle: true),
        navigationBarTheme: NavigationBarThemeData(
          height: 60,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.deepPurple.withValues(alpha: 0.1),
        ),
      ),
      home: _initializing
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_loginData != null
                ? DashboardScreen(
                    onThemeToggle: _toggleTheme,
                    loginData: _loginData!,
                    onLogout: () => setState(() => _loginData = null),
                  )
                : LoginScreen(
                    onThemeToggle: _toggleTheme,
                    onLoginSuccess: (data) => setState(() => _loginData = data),
                  )),
    );
  }
}
