import 'package:flutter/material.dart';
import 'package:shopchecker/View/Screens/shop_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'View/Screens/cart_screen.dart';
import 'View/Screens/settings_screen.dart';
import 'ViewModel/settings_ViewModel.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String theme = ref.watch(settingsProvider).theme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopCheckerPro',
      theme: ThemeData(
        fontFamily: 'OpenSans',
        colorScheme: colorScheme[theme]!,
        // colorScheme: const ColorScheme.light(
        //     background: Color.fromARGB(232, 255, 255, 255),
        //     onPrimary: Colors.black,
        //     primary: Color.fromARGB(255, 255, 255, 255),
        //     secondary: Colors.amber),

        // colorScheme: const ColorScheme.dark(
        //     onPrimary: Colors.black,
        //     primary: Color.fromARGB(255, 255, 255, 255),
        //     secondary: Colors.amber),

        cardTheme: const CardTheme(
          color: Color.fromARGB(255, 255, 255, 255),
        ),

        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Shop(),
        '/cart': (context) => const CartPage(),
        '/settings': (context) => const Settings(),
      },
    );
  }
}
