import 'dart:convert';
import 'dart:io';
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/web_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JournalService {

  static const String resource = "journals/";
  http.Client client = WebClient().client;


  String getUrl() {
    return "${WebClient.url}$resource";
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

    if (response.statusCode != 201) {
      verifyException(json.decode(response.body));
    }
    return true;
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

    if (response.statusCode != 200) {
      verifyException(json.decode(response.body));
    }

    return true;
  }

  Future<bool> delete(String id) async {
    String token = await getToken();
    http.Response response =
        await client.delete(Uri.parse("${getUrl()}$id"), headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      verifyException(json.decode(response.body));
    }

    return true;
  }

  Future<List<Journal>> getAll(String id) async {
    String token = await getToken();

    http.Response response =
        await client.get(Uri.parse("${WebClient.url}users/$id/$resource"), headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode != 200) {
      verifyException(json.decode(response.body));
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

  verifyException(String error) {
    switch (error) {
      case 'jwt expired':
        throw TokenExpiredException();
    }

    throw HttpException(error);
  }

}

class TokenExpiredException implements Exception {}