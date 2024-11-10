import 'package:flutter/material.dart';
import 'package:shopcheckerpro/View/Screens/shop_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'View/Screens/cart_screen.dart';
import 'View/Screens/settings.dart';
import 'ViewModel/Settings_ViewModel.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopCheckerPro',
      theme: ThemeData(
        colorScheme: colorScheme['ligth'],
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
