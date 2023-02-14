import 'dart:convert';

import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/http_interceptors.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalService {
  static const String url = "http://10.0.0.113:3000/";
  static const String resource = "journals/";

  http.Client client =
      InterceptedClient.build(interceptors: [LoggingInterceptor()]);

  String getUrl() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getUrl());
  }

  Future<bool> register(Journal journal) async {
    String jsonJournal = json.encode(journal.toMap());
    String token = await getToken();

    http.Response response = await client.post(getUri(),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonJournal);

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> edit(String id, Journal journal) async {
    String jsonJournal = json.encode(journal.toMap());

    String token = await getToken();
    http.Response response = await client.put(Uri.parse("${getUrl()}$id"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonJournal);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> delete(String id) async {
    String token = await getToken();
    http.Response response =
        await http.delete(Uri.parse("${getUrl()}$id"), headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<List<Journal>> getAll(String id) async {
    String token = await getToken();

    http.Response response =
        await client.get(Uri.parse("${url}users/$id/$resource"), headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode != 200) {
      //TODO: Criar uma exceção personalizada
      throw Exception();
    }

    List<Journal> journalsList = [];
    List<dynamic> jsonList = jsonDecode(response.body);

    for (var jsonMap in jsonList) {
      journalsList.add(Journal.fromMap(jsonMap));
    }
    return journalsList;
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token != null) {
      return token;
    }
    return '';
  }
}
