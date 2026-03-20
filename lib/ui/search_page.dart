import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/services/openweathermap_api.dart';
import 'package:weather_app/ui/weather_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  Future<Iterable<Location>>? locationsSearchResults;

  @override
  Widget build(BuildContext context) {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Ville',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                query = value;
              },
              onSubmitted: (_) {
                if (query.isEmpty) {
                  return;
                }

                setState(() {
                  locationsSearchResults =
                      openWeatherMapApi.searchLocations(query);
                });
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: query.isEmpty
                  ? null
                  : () {
                      setState(() {
                        locationsSearchResults =
                            openWeatherMapApi.searchLocations(query);
                      });
                    },
              child: const Text('Rechercher'),
            ),
            const SizedBox(height: 16),
            if (query.isEmpty)
              const Text('Saisissez une ville dans la barre de recherche.')
            else if (locationsSearchResults == null)
              const Text('Appuyez sur "Rechercher" pour lancer la recherche.')
            else
              Expanded(
                child: FutureBuilder<Iterable<Location>>(
                  future: locationsSearchResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Une erreur est survenue.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Aucun résultat pour cette recherche.'),
                      );
                    }

                    final locations = snapshot.data!.toList();

                    return ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final location = locations[index];

                        return ListTile(
                          leading: const Icon(Icons.location_city),
                          title: Text(location.name),
                          subtitle: Text('${location.name}, ${location.country}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => WeatherPage(
                                  locationName: location.name,
                                  latitude: location.lat,
                                  longitude: location.lon,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}