import 'package:flutter/material.dart';

import '../../../data/mock_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = MockData.events.where((event) {
      final text = '${event.title} ${event.description ?? ''}'.toLowerCase();
      return text.contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              labelText: 'Buscar eventos e compromissos',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 18),
          ...results.map(
            (event) => Card(
              child: ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(event.title),
                subtitle: Text(event.category ?? 'Sem categoria'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
