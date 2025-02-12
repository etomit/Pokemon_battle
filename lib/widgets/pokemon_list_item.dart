import 'package:flutter/material.dart';

class PokemonListItem extends StatelessWidget {
  final int id;
  final String name;
  final String imageUrl;
  final VoidCallback onHover;

  const PokemonListItem({
    Key? key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.onHover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        color: Colors.white,
        child: ListTile(
          leading: Image.network(imageUrl, width: 50, height: 50),
          title: Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
