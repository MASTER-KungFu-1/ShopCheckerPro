import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achivements extends ChangeNotifier {
  Achivements();

  List<Map> achivements = [
    {
      'title': 'Мастер поиска скидок',
      'description': 'Сэкономьте более 3000 рублей сумарно ',
      'currentProgress': 0,
      'maxProgress': 3000,
      'progressPercentage': 0,
    },
    {
      'title': 'Гуру поиска скидок',
      'description': 'Сэкономьте более 10000 рублей сумарно ',
      'currentProgress': 0,
      'maxProgress': 10000,
      'progressPercentage': 0,
    },
    {
      'title': 'Начинающий искатель скидок',
      'description': 'Сэкономьте более 300 рублей сумарно ',
      'currentProgress': 0,
      'maxProgress': 300,
      'progressPercentage': 0,
    },
    {
      'title': 'Уверенный искатель скидок',
      'description': 'Сэкономьте более 10000 рублей сумарно ',
      'currentProgress': 0,
      'maxProgress': 700,
      'progressPercentage': 0,
    },
  ];

  List<Map> getAchivements() {
    return achivements;
  }

  List<Map> getDoneAchivements() {
    List<Map> doneAchivements = [];
    for (int i = 0; i < achivements.length; i++) {
      if (achivements[i]['currentProgress'] == achivements[i]['maxProgress']) {
        doneAchivements.add(achivements[i]);
      }
    }
    return doneAchivements;
  }

  void addAchivement(String title, String description,
      [int? currentProgress, int? maxProgress]) {
    currentProgress ??= 0;
    maxProgress ??= 100;

    achivements.add({
      'title': title,
      'description': description,
      'currentProgress': currentProgress,
      'maxProgress': maxProgress,
      'progressPercentage': (currentProgress / maxProgress) * 100,
    });
    notifyListeners();
  }

  void updateAchivements(List<Map> newachivements) {
    achivements = newachivements;

    notifyListeners();
  }
}

class PreferencesService {
  // Сохранить строку в SharedPreferences
  Future<void> saveTheme(String achivements) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'Achivements', achivements); // Сохраняем значение с ключом 'theme'
  }

  // Получить строку из SharedPreferences
  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('Achivements');
  }

  // Удалить значение
  Future<void> removeTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('Achivements');
  }
}
