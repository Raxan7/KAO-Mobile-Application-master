import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final String name;
  final String status;
  final Function() onEdit;

  const PropertyCard({
    super.key,
    required this.name,
    required this.status,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    print("We are here");
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(name),
        subtitle: Text(status),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
