import 'package:flutter/material.dart';

class DrawerListview extends StatelessWidget {
  const DrawerListview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            leading: const Icon(
              Icons.star,
              color: Color.fromARGB(255, 214, 198, 53),
            ),
            title: const Text('Trip Scores: 67'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Bookmarks'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
