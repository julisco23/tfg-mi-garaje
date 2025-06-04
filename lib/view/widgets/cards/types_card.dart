import 'package:flutter/material.dart';

class TypesCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool contains;
  final VoidCallback? onPressed;

  const TypesCard({
    super.key,
    required this.title,
    required this.icon,
    this.contains = false,
    required this.onPressed,
  });

  @override
  State<TypesCard> createState() => _TypesCardState();
}

class _TypesCardState extends State<TypesCard> {
  late String title;

  @override
  void initState() {
    super.initState();
    title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        trailing: widget.contains
            ? null
            : IconButton(
                onPressed: widget.onPressed,
                icon: Icon(
                  widget.icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
      ),
    );
  }
}
