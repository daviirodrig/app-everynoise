import 'package:app_everynoise/all_genres_page.dart';

import 'genrepage.dart';
import 'utils/network.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> genreButtons = [];
  bool loading = false;
  List<String> genres = [];

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

  Future<List<String>> _getListOfGenres() async {
    dynamic res = await getAllgenres();
    List l = res["genres"];
    return l.map<String>((e) => e["name"]!).toList();
  }

  void _submitArtist(String val) {
    setState(() {
      loading = true;
    });
    searchArtist(val).then((v) {
      genreButtons = [];

      for (var genre in v) {
        Text buttonText = Text(
          genre,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );

        ButtonStyle btnStyle = ElevatedButton.styleFrom(
          backgroundColor: Colors.pink.withAlpha(80),
          side: const BorderSide(
            color: Colors.pink,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );

        ElevatedButton genreButton = ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _goToGenrePage(genre);
          },
          child: buttonText,
        );

        genreButtons.add(
          Padding(
            padding:
                const EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 2),
            child: genreButton,
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
  void initState() {
    super.initState();
    _getListOfGenres().then((value) => genres = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllGenresPage(),
                ),
              );
            },
            icon: const Icon(Icons.apps),
          )
        ],
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
                ? const CircularProgressIndicator()
                : Wrap(
                    children: genreButtons,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Autocomplete(
              optionsBuilder: (TextEditingValue textEditingValue) {
                Iterable<String> results = genres.where(
                  (item) => item
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()),
                );

                return results;
              },
              onSelected: (option) {
                _goToGenrePage(option);
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                _genrecontrol.text = textEditingController.text;
                // textEditingController.text = _genrecontrol.text;
                // _genreFocus.addListener(() {
                //   if (!_genreFocus.hasFocus) {
                //     _goToGenrePage(_genrecontrol.text);
                //   }
                // });
                return TextField(
                  controller: textEditingController,
                  onSubmitted: _goToGenrePage,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: "Go to genre",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_right_alt),
                      iconSize: 38.0,
                      onPressed: () {
                        _goToGenrePage(_genrecontrol.text);
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 16.0,
                    child: SizedBox(
                      width: 370,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: const Color(0xFF000000),
                        )),
                        child: ListView.separated(
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.pinkAccent,
                          ),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
