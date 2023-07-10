import 'dart:math';

import 'package:app_everynoise/utils/network.dart';
import 'package:app_everynoise/utils/others.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AllGenresPage extends StatefulWidget {
  const AllGenresPage({super.key});

  @override
  State<AllGenresPage> createState() => _AllGenresPageState();
}

class _AllGenresPageState extends State<AllGenresPage> {
  AudioPlayer player = AudioPlayer();
  bool _expanded = false;
  int _selectedIndex = 0;
  bool isLoading = true;

  void _scanGenres() {
    Random random = Random();
    int listSize = _genresData.length;

    int index = random.nextInt(listSize);
    dynamic genre = _genresData[index];
    // if artist has no preview url, get another one
    while (genre["preview_url"].isEmpty) {
      index = random.nextInt(listSize);
      genre = _genresData[index];
    }
    setState(() {
      _selectedIndex = index;
      _expanded = true;
    });
    showToast(context, 'Now playing: ${genre["name"]}');
    _playSong(genre);
  }

  void _playSong(genre) async {
    await player.stop();
    AudioPlayer newPlayer = AudioPlayer();
    player = newPlayer;
    String url = genre["preview_url"];
    if (url.isNotEmpty) {
      await player.setUrl(url);
      await player.setLoopMode(LoopMode.one);
      player.play();
      setState(() {});
    } else {
      showToast(
        context,
        "No preview available for genre: ${genre["name"]}",
      );
    }
  }

  List _filteredData = [];
  List _genresData = [];

  void _filterList(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredData = _genresData;
      } else {
        _filteredData = _genresData
            .where((item) =>
                item["name"].toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  void _loadGenresList() {
    var res = getAllgenres();
    // _genresData =
    //     List.generate(10000, (index) => {"id": index, "name": "Item $index"});
    res.then((value) {
      _genresData = value["genres"];
      _filteredData = _genresData;
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
    _loadGenresList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _scanGenres,
            icon: const Icon(
              Icons.shuffle,
            ),
          ),
        ],
      ),
      body: !isLoading
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Search",
                      hintText: "Enter search",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _filterList(value),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredData.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic artist = _filteredData[index];

                      String hColor =
                          artist["style"][0].split(" ")[1].substring(1);
                      String prefix =
                          artist["preview_url"].isEmpty ? "0x55" : "0xFF";

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
                            '${_filteredData[index]["song_title"]}',
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        return const Divider();
                      }
                    },
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: player.playing
          ? FloatingActionButton(
              onPressed: () {
                player.stop();
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
