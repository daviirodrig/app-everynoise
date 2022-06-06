import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app_everynoise/playlists_page.dart';
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
  Timer? timer;

  Future<Map<String, dynamic>> _networkGenrePage(String q) async {
    await dotenv.load();
    String url = dotenv.get("HOST");

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

  void _scanGenres() {
    Random random = Random();
    int listSize = genreArtists["artists"].length;
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _playSong(random.nextInt(listSize));
    });
  }

  void _playSong(index) async {
    String url = genreArtists["artists"][index]["preview_url"];
    if (url.isNotEmpty) {
      await player.setUrl(url);
      await player.setLoopMode(LoopMode.one);
      player.play();
      setState(() {});
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

  void _goToPlaylists() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistsPage(
          list: genreArtists["playlists"],
        ),
      ),
    );
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
        title: Text(widget.genre),
        actions: [
          IconButton(
            onPressed: _scanGenres,
            icon: const Icon(
              Icons.sensors,
            ),
          ),
          IconButton(
              onPressed: _goToPlaylists,
              icon: const Icon(Icons.my_library_music_rounded))
        ],
      ),
      body: genreArtists.isNotEmpty
          ? ListView.separated(
              itemCount: genreArtists["artists"].length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    genreArtists["artists"][index]["name"],
                    style: TextStyle(
                      color: Color(int.parse(
                          genreArtists["artists"][index]["preview_url"].isEmpty
                              ? "0x55" +
                                  genreArtists["artists"][index]["style"][0]
                                      .split(" ")[1]
                                      .substring(1)
                              : "0xFF" +
                                  genreArtists["artists"][index]["style"][0]
                                      .split(" ")[1]
                                      .substring(1))),
                    ),
                  ),
                  trailing: const Icon(Icons.audiotrack_rounded),
                  onTap: () => _playSong(index),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: player.playing
          ? FloatingActionButton(
              onPressed: () {
                player.stop();
                timer?.cancel();
                setState(() {});
              },
              child: const Icon(Icons.stop),
            )
          : Container(),
    );
  }
}
