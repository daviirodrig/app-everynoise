import 'dart:async';
import 'dart:math';
import 'playlists_page.dart';
import 'utils/network.dart';
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
  bool _expanded = false;
  int _selectedIndex = 0;

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
        setState(() {
          _selectedIndex = index;
          _expanded = true;
        });
        _playSong(artist);
      },
    );
  }

  void _playSong(artist) async {
    if (player.playing) {
      player.pause();
    }
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
                  onTap: () => {
                    setState(() {
                        _playSong(artist);
                        _expanded = true;
                      _selectedIndex = index;
                    })
                  },
                );
              },
              separatorBuilder: (context, index) {
                if (_expanded && index == _selectedIndex) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      '${genreArtists["artists"][index]["song_title"]}',
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return const Divider();
                }
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
                setState(() {
                  _expanded = false;
                });
              },
              child: const Icon(Icons.stop),
            )
          : Container(),
    );
  }
}
