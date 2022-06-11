import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> searchArtist(String q) async {
  String url = "https://e.davi.gq/";
  try {
    http.Response res = await http.get(
      Uri.parse('$url/search/artist/$q'),
    );
    Map<String, dynamic> resJson = jsonDecode(utf8.decode(res.bodyBytes));
    return resJson['genres'];
  } catch (e) {
    return [e.toString()];
  }
}

Future<Map<String, dynamic>> searchGenrePage(String q) async {
  String url = "https://e.davi.gq/";

  try {
    http.Response res = await http.get(
      Uri.parse('$url/genre/$q'),
    );
    Map<String, dynamic> resJson = jsonDecode(utf8.decode(res.bodyBytes));

    return resJson;
  } catch (e) {
    return {"e": e.toString()};
  }
}
