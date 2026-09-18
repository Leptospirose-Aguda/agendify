import 'package:flutter/material.dart';

import '../../../models/event_model.dart';
import '../../../services/event_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _service = EventService();
  String _query = '';
  late Future<List<EventModel>> _events;

  @override
  void initState() {
    super.initState();
    _events = _service.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(labelText: 'Buscar eventos e compromissos', prefixIcon: Icon(Icons.search)),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<EventModel>>(
            future: _events,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const Text('Não foi possível consultar os eventos.');
              final query = _query.toLowerCase();
              final results = (snapshot.data ?? []).where((event) {
                final text = '${event.title} ${event.description ?? ''} ${event.location ?? ''} ${event.category ?? ''}'.toLowerCase();
                return text.contains(query);
              });
              return Column(children: results.map((event) => Card(
                child: ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(event.title),
                  subtitle: Text(event.category ?? 'Sem categoria'),
                ),
              )).toList());
            },
          ),
        ],
      ),
    );
  }
}
