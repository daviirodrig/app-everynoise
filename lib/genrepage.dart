import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    await dotenv.load();
    String url = dotenv.get("HOST");

    try {
      http.Response res = await http.get(
        Uri.parse('$url/genre?q=$q'),
      );
      Map<String, dynamic> resJson = jsonDecode(utf8.decode(res.bodyBytes));

      return resJson;
    } catch (e) {
      return {"e": e.toString()};
    }
  }

  void _playSong(index) async {
    await player.setUrl(genreArtists["artists"][index]["preview_url"]);
    await player.setLoopMode(LoopMode.one);
    player.play();
    setState(() {});
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
      appBar: AppBar(
        title: const Text("Genre Page"),
      ),
      body: Center(
        child: genreArtists.isNotEmpty
            ? ListView.builder(
                itemCount: genreArtists["artists"].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(genreArtists["artists"][index]["name"]),
                    trailing: GestureDetector(
                      child: const Icon(Icons.audiotrack_rounded),
                      onTap: () => _playSong(index),
                    ),
                  );
                },
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: player.playing
          ? FloatingActionButton(
              onPressed: () {
                player.stop();
                setState(() {});
              },
              child: const Icon(Icons.stop),
            )
          : Container(),
    );
  }
}
