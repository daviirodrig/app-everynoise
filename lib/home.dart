import 'genrepage.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> searched = [];
  bool loading = false;

  Future<List<dynamic>> _searchArtist(String q) async {
    await dotenv.load();
    String url = dotenv.get("HOST");
    try {
      http.Response res = await http.get(
        Uri.parse('$url/artist?q=$q'),
      );
      Map<String, dynamic> resJson = jsonDecode(utf8.decode(res.bodyBytes));
      return resJson['genres'];
    } catch (e) {
      return [e.toString()];
    }
  }

  void _submit(String val) {
    setState(() {
      loading = true;
    });
    _searchArtist(val).then((v) {
      searched = [];
      for (var i in v) {
        String textStr;
        if (i.toString() != v.last.toString()) {
          textStr = "$i | ";
        } else {
          textStr = "$i";
        }
        searched.add(GestureDetector(
          child: Text(
            textStr,
            style: const TextStyle(fontSize: 20),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GenrePage(
                  genre: i,
                ),
              ),
            );
          },
        ));
      }
      setState(() {
        loading = false;
      });
    });
  }

  final TextEditingController _textcontrol = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: _submit,
              controller: _textcontrol,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _submit(_textcontrol.text);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: loading
                ? const CircularProgressIndicator(
                    backgroundColor: Colors.deepPurple,
                    color: Colors.teal,
                    strokeWidth: 5,
                  )
                : Wrap(
                    children: searched,
                  ),
          ),
        ],
      ),
    );
  }
}
