import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keywarden/providers/auth_provider.dart';
import 'package:keywarden/screens/create_master_key.dart';
import 'package:keywarden/screens/login.dart';
import 'package:keywarden/utils/encryption.dart';
import 'package:keywarden/utils/router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  await Hive.initFlutter();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ], child: const KeyWarden()));
}

class KeyWarden extends StatelessWidget {
  const KeyWarden({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: "Key Warden",
      debugShowCheckedModeBanner: false,
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
    );
  }
}

class Boarding extends StatefulWidget {
  const Boarding({super.key});

  @override
  State<Boarding> createState() => _BoardingState();
}

class _BoardingState extends State<Boarding> {
  @override
  void initState() {
    super.initState();
    Preferences.getItem('masterKey').then((value) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) =>
                  value != null ? const Login() : const CreateMasterKey()),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}

final defaultFontStyle = GoogleFonts.poppins();
final InputBorder border = OutlineInputBorder(
  borderSide: const BorderSide(width: 0, color: Colors.transparent),
  borderRadius: BorderRadius.circular(20),
);

ThemeData lightTheme(BuildContext context) {
  return ThemeData.light(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green),
    scaffoldBackgroundColor: const Color.fromRGBO(240, 244, 247, 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: defaultFontStyle.copyWith(color: Colors.black),
      headlineMedium: defaultFontStyle.copyWith(color: Colors.black),
      headlineSmall: defaultFontStyle.copyWith(color: Colors.black),
      bodyLarge: defaultFontStyle.copyWith(color: Colors.black),
      bodyMedium: defaultFontStyle.copyWith(color: Colors.black),
      bodySmall: defaultFontStyle.copyWith(color: Colors.black),
      displayLarge: defaultFontStyle.copyWith(color: Colors.black),
      displayMedium: defaultFontStyle.copyWith(color: Colors.black),
      displaySmall: defaultFontStyle.copyWith(color: Colors.black),
      titleLarge: defaultFontStyle.copyWith(color: Colors.black),
      titleMedium: defaultFontStyle.copyWith(color: Colors.black),
      titleSmall: defaultFontStyle.copyWith(color: Colors.black),
      labelLarge: defaultFontStyle.copyWith(color: Colors.black),
      labelMedium: defaultFontStyle.copyWith(color: Colors.black),
      labelSmall: defaultFontStyle.copyWith(color: Colors.black),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.black,
      textColor: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: Colors.black38),
      hintStyle: const TextStyle(color: Colors.black38),
      floatingLabelStyle: const TextStyle(color: Colors.black38),
      fillColor: Colors.black.withAlpha(50),
      border: border,
    ),
  );
}

ThemeData darkTheme(BuildContext context) {
  return ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green),
    scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: defaultFontStyle.copyWith(color: Colors.white),
      headlineMedium: defaultFontStyle.copyWith(color: Colors.white),
      headlineSmall: defaultFontStyle.copyWith(color: Colors.white),
      bodyLarge: defaultFontStyle.copyWith(color: Colors.white),
      bodyMedium: defaultFontStyle.copyWith(color: Colors.white),
      bodySmall: defaultFontStyle.copyWith(color: Colors.white),
      displayLarge: defaultFontStyle.copyWith(color: Colors.white),
      displayMedium: defaultFontStyle.copyWith(color: Colors.white),
      displaySmall: defaultFontStyle.copyWith(color: Colors.white),
      titleLarge: defaultFontStyle.copyWith(color: Colors.white),
      titleMedium: defaultFontStyle.copyWith(color: Colors.white),
      titleSmall: defaultFontStyle.copyWith(color: Colors.white),
      labelLarge: defaultFontStyle.copyWith(color: Colors.white),
      labelMedium: defaultFontStyle.copyWith(color: Colors.white),
      labelSmall: defaultFontStyle.copyWith(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    primaryIconTheme: const IconThemeData(color: Colors.white),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white,
      textColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white38),
        hintStyle: const TextStyle(color: Colors.white38),
        floatingLabelStyle: const TextStyle(color: Colors.white38),
        fillColor: Colors.white12,
        border: border),
  );
}
