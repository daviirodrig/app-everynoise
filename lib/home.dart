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
        Uri.parse('$url/search/artist/$q'),
      );
      Map<String, dynamic> resJson = jsonDecode(utf8.decode(res.bodyBytes));
      return resJson['genres'];
    } catch (e) {
      return [e.toString()];
    }
  }

  void _submitGenre(String val) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenrePage(
          genre: val,
        ),
      ),
    );
  }

  void _submitArtist(String val) {
    setState(() {
      loading = true;
    });
    _searchArtist(val).then((v) {
      searched = [];
      for (var genre in v) {
        ElevatedButton genreButton = ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GenrePage(
                  genre: genre,
                ),
              ),
            );
          },
          child: Text(
            genre,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.pink.withAlpha(80),
            side: const BorderSide(
              color: Colors.pink,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );

        searched.add(
          Padding(
            child: genreButton,
            padding:
                const EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 2),
          ),
        );
      }
      setState(() {
        loading = false;
      });
    });
  }

  final TextEditingController _genrecontrol = TextEditingController();
  final TextEditingController _artistcontrol = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                right: 8.0, left: 8.0, bottom: 8.0, top: 16.0),
            child: TextField(
              onSubmitted: _submitArtist,
              controller: _artistcontrol,
              decoration: InputDecoration(
                labelText: "Search Artist",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _submitArtist(_artistcontrol.text);
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
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: _submitGenre,
                controller: _genrecontrol,
                decoration: InputDecoration(
                  labelText: "Go to genre",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_right_alt),
                    iconSize: 38.0,
                    onPressed: () {
                      _submitGenre(_genrecontrol.text);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ))
        ],
      ),
    );
  }
}
