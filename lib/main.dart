import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Everynoise',
      theme: ThemeData(
          primarySwatch: Colors.green,
          textTheme: GoogleFonts.robotoCondensedTextTheme()),
      home: const MyHomePage(title: 'EveryNoise'),
    );
  }
}

class GenrePage extends StatefulWidget {
  GenrePage({Key? key, required this.genre}) : super(key: key);

  final String genre;
  final List<Text> genreArtists = [];

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  Map<String, dynamic> genreArtists = {};
  final AudioPlayer player = AudioPlayer();

  Future<Map<String, dynamic>> _networkGenrePage(String q) async {
    String url = dotenv.get("HOST");

    try {
      http.Response res = await http.get(Uri.parse('$url/genre?q=$q'));
      Map<String, dynamic> resJson = jsonDecode(res.body);

      return resJson;
    } catch (e) {
      return {"e": e.toString()};
    }
  }

  void _loadArtistsList() {
    var res = _networkGenrePage(widget.genre);
    res.then((value) {
      genreArtists = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadArtistsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Genre Page")),
      body: Center(
          child: genreArtists.isNotEmpty
              ? ListView.builder(
                  itemCount: genreArtists["artists"].length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(genreArtists["artists"][index]["name"]),
                      trailing: GestureDetector(
                        child: const Icon(Icons.audiotrack_rounded),
                        onTap: () async {
                          if (!player.playing) {
                            await player.setUrl(
                                genreArtists["artists"][index]["preview_url"]);
                            await player.setLoopMode(LoopMode.one);
                            player.play();
                          } else {
                            player.stop();
                          }
                        },
                      ),
                    );
                  })
              : const CircularProgressIndicator()),
    );
  }
}

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
    String url = dotenv.get("HOST");
    try {
      http.Response res =
          await http.get(Uri.parse('$url/artist_genre?artist=$q'));
      Map<String, dynamic> resJson = jsonDecode(res.body);
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
          child: Text(textStr, style: const TextStyle(fontSize: 20)),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => GenrePage(genre: i)));
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
                  border: const OutlineInputBorder()),
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
                    ))
        ],
      ),
    );
  }
}
