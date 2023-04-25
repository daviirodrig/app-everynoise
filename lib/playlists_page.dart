import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({Key? key, required this.list}) : super(key: key);
  final List<dynamic> list;

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
      ),
      body: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          String name = widget.list[index].entries.first.key.toString();
          Uri url =
              Uri.parse(widget.list[index].entries.first.value.toString());
          //String spotifyUri = "spotify:playlist:${url.split('/').last}";
          return ListTile(
              title: Text(name),
              subtitle: Text(url.toString()),
              // ontap open link in browser
              onTap: () async {
                launchUrl(url, mode: LaunchMode.externalApplication);
              });
        },
      ),
    );
  }
}
