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
                ? const CircularProgressIndicator()
                : Wrap(
                    children: genreButtons,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: _goToGenrePage,
              controller: _genrecontrol,
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
            ),
          )
        ],
      ),
    );
  }
}
