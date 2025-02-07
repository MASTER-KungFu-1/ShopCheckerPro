import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopchecker/Model/Product.dart';

class ApiService {
  final String baseUrl = 'http://185.117.154.91:8000';

  Future<List<Product>> fetchPerekrestokProducts(String query) async {
    final url = "$baseUrl/perekrestok/$query/";
    final response = await http.get(Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      Map<String, dynamic> data = json.decode(decodedResponse);
      final List<dynamic> data_decode = data["result"];
      return data_decode
          .map((item) => Product.fromPerekrestokJson(item))
          .toList();
    } else {
      print('Ошибка загрузки информации с магазина Перекресток');
      return List.empty();
    }
  }

  Future<List<Product>> fetchMagnitProducts(String query) async {
    final url = '$baseUrl/magnit/$query/';
    final response = await http.get(Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      Map<String, dynamic> data = json.decode(decodedResponse);

      final List<dynamic> data_decode = data["result"];

      return data_decode.map((item) => Product.fromMagnitJson(item)).toList();
    } else {
      print('Ошибка загрузки информации с магазина Магнит');
      return List.empty();
    }
  }

  Future<List<Product>> fetchSearchProducts(String query) async {
    //final url = '$baseUrl/search/$query/';
    if (query == "") {
      query = "кола";
    } else if (query.length < 3) {}
    final url = "$baseUrl/search/$query/";

    final response = await http.get(Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);

      Map<String, dynamic> data = json.decode(decodedResponse);
      // if (data['result'].runtimeType != List<dynamic>) {
      //   print(data['result'][0]);
      // }
      if (data['result'] == []) {
        print("ПУСТОЙ СПИСОК");
      }
      final List<dynamic> dataDecode = data["result"];
      // for (var item in dataDecode) {
      //   if (item.runtimeType != Map<String, dynamic>) {
      //     print("ТУТ ОШИБКА!!!! " + item);
      //   }
      // }

      return dataDecode.map((item) => Product.fromSearchJson(item)).toList();
    } else {
      print("Ошибка загрузки информации с поиска");
      return List.empty();
    }
  }

  Future<List> postRecomendedCart(Map<String, dynamic> cartList) async {
    final initialUrl = "$baseUrl/cluster/";
    final body = json.encode(cartList);

    var response = await http.post(
      Uri.parse(initialUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    // Обработка перенаправлений
    while (response.statusCode == 307) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl == null) {
        print('Не удалось получить URL перенаправления');
        return List.empty();
      }

      response = await http.post(
        Uri.parse(redirectUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    }

    // Проверка на успешный ответ
    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedResponse);

      if (data.containsKey('result')) {
        return List.from(data['result']);
      } else if (data.containsKey('cluster')) {
        return List.from(data['cluster']);
      } else {
        print('Ответ не содержит ключ "result"');
        return List.empty();
      }
    } else {
      print('Ошибка: ${response.statusCode}');
      print('Ответ: ${response.body}');
      return List.empty();
    }
  }
}
