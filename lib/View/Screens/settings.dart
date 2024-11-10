import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text("Настройки")),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          if (index == 0) {
            Navigator.pop(
              context,
              '/',
            );
          }
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/cart');
          }
        },
        currentIndex: 2,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: "Товары",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Корзина",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Настройки",
          ),
        ],
      ),
    ));
  }
}
