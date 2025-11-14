import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/splash_screen.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🔵 Firebase初期化開始...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('✅ Firebase初期化完了');

  // 日本語ロケールの初期化
  await initializeDateFormatting('ja_JP', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        locale: const Locale('ja', 'JP'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja', 'JP'), Locale('en', 'US')],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          segmentedButtonTheme: SegmentedButtonThemeData(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (states) => states.contains(MaterialState.selected)
                    ? const Color(0xFF0083DF)
                    : null,
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                (states) => states.contains(MaterialState.selected)
                    ? Colors.white
                    : const Color(0xFF0083DF),
              ),
              side: MaterialStateProperty.resolveWith<BorderSide?>(
                (states) => states.contains(MaterialState.selected)
                    ? const BorderSide(color: Color(0xFF0083DF))
                    : const BorderSide(color: Color(0xFF0083DF), width: 0.3),
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083DF),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white,
            modalBackgroundColor: Colors.white,
          ),
          datePickerTheme: const DatePickerThemeData(
            backgroundColor: Colors.white,
          ),
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Colors.white,
          ),
          popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
          dropdownMenuTheme: const DropdownMenuThemeData(
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              fixedSize: WidgetStatePropertyAll(Size(double.infinity, 300)),
            ),
          ),
          listTileTheme: const ListTileThemeData(
            selectedTileColor: Colors.white,
            selectedColor: Colors.black87,
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
