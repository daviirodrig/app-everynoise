import 'dart:async';
import 'dart:math';
import 'package:app_everynoise/playlists_page.dart';
import 'package:app_everynoise/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'utils/others.dart';

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

  void _scanGenres() {
    Random random = Random();
    int listSize = genreArtists["artists"].length;
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        int index = random.nextInt(listSize);
        dynamic artist = genreArtists["artists"][index];
        // if artist has no preview url, get another one
        while (artist["preview_url"].isEmpty) {
          index = random.nextInt(listSize);
          artist = genreArtists["artists"][index];
        }
        _playSong(artist);
      },
    );
  }

  void _playSong(artist) async {
    String url = artist["preview_url"];
    if (url.isNotEmpty) {
      await player.setUrl(url);
      await player.setLoopMode(LoopMode.one);
      player.play();
      setState(() {});
    } else {
      showToast(
        context,
        "No preview available for artist: ${artist["name"]}",
      );
    }
  }

  void _loadArtistsList() {
    var res = searchGenrePage(widget.genre);
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
    timer?.cancel();
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
            icon: const Icon(
              Icons.my_library_music_rounded,
            ),
          )
        ],
      ),
      body: genreArtists.isNotEmpty
          ? ListView.separated(
              itemCount: genreArtists["artists"].length,
              itemBuilder: (context, index) {
                dynamic artist = genreArtists["artists"][index];

                String hColor = artist["style"][0].split(" ")[1].substring(1);
                String prefix = artist["preview_url"].isEmpty ? "0x55" : "0xFF";

                Color color = Color(
                  int.parse(prefix + hColor),
                );

                return ListTile(
                  title: Text(
                    artist["name"],
                    style: TextStyle(
                      color: color,
                    ),
                  ),
                  trailing: const Icon(Icons.audiotrack_rounded),
                  onTap: () => _playSong(artist),
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
