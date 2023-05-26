import 'package:app_everynoise/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'genrepage.dart';

class AllGenresWidget extends StatefulWidget {
  const AllGenresWidget({super.key});

  @override
  State<AllGenresWidget> createState() => _AllGenresWidgetState();
}

class _AllGenresWidgetState extends State<AllGenresWidget> {
  final AudioPlayer player = AudioPlayer();
  final TextEditingController _genreControl = TextEditingController();
  bool isLoading = true;
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

  void _goToGenrePage(String genre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenrePage(
          genre: genre,
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
    super.initState();
    _loadGenresList();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Column(
            children: [
              TextField(
                controller: _genreControl,
                onSubmitted: _goToGenrePage,
                onChanged: (value) => _filterList(value),
                decoration: InputDecoration(
                  labelText: "Go to genre",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_right_alt),
                    iconSize: 38.0,
                    onPressed: () {
                      _goToGenrePage(_genreControl.text);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
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
                        _goToGenrePage(artist["name"])
                        // setState(() {
                        //   _playSong(artist);
                        //   _expanded = true;
                        //   _selectedIndex = index;
                        // })
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
