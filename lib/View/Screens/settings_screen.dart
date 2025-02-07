import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopchecker/ViewModel/settings_ViewModel.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  // @override
  // void initState() {
  //   super.initState();
  //   //bool activeThemeLight = false;
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Настройки',
        ),
        centerTitle: true,
      ),
      body: ListView(children: [
        Card(
          child: Column(
            children: [
              Center(
                child: Text(
                  'Достижения',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              const Text(
                'Вы еще не успели получить достижение!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                'Настройки',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              Checkbox(
                  value: ref.watch(settingsProvider).activeThemeCheckBox,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateTheme(value! ? 'light' : 'dark');
                  }),
            ],
          ),
        ),
      ]),
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
