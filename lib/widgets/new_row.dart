import 'package:flutter/material.dart';

class NewRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap; 

  const NewRow({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}
