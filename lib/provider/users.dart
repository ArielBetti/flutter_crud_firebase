import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_crud/data/dummy_users.dart';
import 'package:flutter_crud/models/user.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  bool _isInitialized = false;
  static const _baseURL = 'list-af0e3-default-rtdb.firebaseio.com';
  final Map<String, User> _items = {...DUMMY_USERS};

  List<User> get all {
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt(i);
  }

  Future<void> getUser() async {
    final response = await http.get(Uri.http(_baseURL, "users.json"));
    Map<String, User> _items = {};

    Map<dynamic, Map<String, dynamic>> map = {};
    Map<String, dynamic> parsedResponse = jsonDecode(response.body);

    parsedResponse.forEach((key, value) {
      _items.putIfAbsent(
          key,
          () => User(
                id: key,
                name: value['name'],
                email: value['email'],
                avatarUrl: value['avatarUrl'],
              ));
    });

    // atribui a lista atualizada para a variável _items
    this._items.clear();
    this._items.addAll(_items);
  }

  Future<void> put(User user) async {
    if (user == null) {
      return;
    }

    if (user.id != null &&
        user.id.trim().isNotEmpty &&
        _items.containsKey(user.id)) {
      final userId = user.id;
      final response = await http.put(Uri.http(_baseURL, "users/$userId.json"),
          body: json.encode({
            'name': user.name,
            'email': user.email,
            'avatarUrl': user.avatarUrl
          }));
      _items.update(
        user.id,
        (_) => User(
          id: user.id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        ),
      );
    } else {
      final response = await http.post(Uri.http(_baseURL, "users.json"),
          body: json.encode({
            'name': user.name,
            'email': user.email,
            'avatarUrl': user.avatarUrl
          }));

      final id = json.decode(response.body)['name'];

      _items.putIfAbsent(
        id,
        () => User(
          id: id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        ),
      );
    }
    notifyListeners();
  }

  void remove(User user) {
    if (user != null && user.id != null) {
      _items.remove(user.id);
      notifyListeners();
    }
  }
}
