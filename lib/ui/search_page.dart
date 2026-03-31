import 'package:flutter/material.dart'; // Widgets Flutter
import 'package:provider/provider.dart'; // Accès aux services
import 'package:weather_app/models/location.dart'; // Modèle Location
import 'package:weather_app/services/openweathermap_api.dart'; // API météo
import 'package:weather_app/ui/weather_page.dart'; // Page météo

/* ============================================================
   PAGE DE RECHERCHE
   Permet de :
   - saisir une ville
   - appeler l’API
   - afficher les résultats
   - naviguer vers WeatherPage
============================================================ */

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = ''; // Texte saisi par l'utilisateur

  // Future contenant les résultats de recherche (API)
  Future<Iterable<Location>>? locationsSearchResults;

  @override
  Widget build(BuildContext context) {
    // Récupère le service API via Provider
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /* ============================================================
               CHAMP DE SAISIE
            ============================================================ */

            TextField(
              decoration: const InputDecoration(
                labelText: 'Ville',
                border: OutlineInputBorder(),
              ),

              // Mise à jour du texte saisi
              onChanged: (value) {
                query = value;
              },

              // Appui sur "Entrée"
              onSubmitted: (_) {
                if (query.isEmpty) return;

                // Lance la recherche API
                setState(() {
                  locationsSearchResults =
                      openWeatherMapApi.searchLocations(query);
                });
              },
            ),

            const SizedBox(height: 12),

            /* ============================================================
               BOUTON RECHERCHER
            ============================================================ */

            ElevatedButton(
              // Bouton désactivé si champ vide
              onPressed: query.isEmpty
                  ? null
                  : () {
                      setState(() {
                        // Appel API
                        locationsSearchResults =
                            openWeatherMapApi.searchLocations(query);
                      });
                    },

              child: const Text('Rechercher'),
            ),

            const SizedBox(height: 16),

            /* ============================================================
               AFFICHAGE SELON L’ETAT
            ============================================================ */

            if (query.isEmpty)
              // Rien tapé
              const Text('Saisissez une ville dans la barre de recherche.')

            else if (locationsSearchResults == null)
              // Pas encore lancé
              const Text('Appuyez sur "Rechercher" pour lancer la recherche.')

            else
              // Résultats
              Expanded(
                child: FutureBuilder<Iterable<Location>>(

                  // Future à observer
                  future: locationsSearchResults,

                  builder: (context, snapshot) {

                    /* =============================
                       CAS 1 : chargement
                    ============================= */
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    /* =============================
                       CAS 2 : erreur
                    ============================= */
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Une erreur est survenue.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    /* =============================
                       CAS 3 : aucun résultat
                    ============================= */
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Aucun résultat pour cette recherche.'),
                      );
                    }

                    /* =============================
                       CAS 4 : données OK
                    ============================= */

                    final locations = snapshot.data!.toList();

                    return ListView.builder(
                      itemCount: locations.length,

                      itemBuilder: (context, index) {
                        final location = locations[index];

                        return ListTile(
                          leading: const Icon(Icons.location_city),

                          // Nom de la ville
                          title: Text(location.name),

                          // Pays
                          subtitle: Text(
                              '${location.name}, ${location.country}'),

                          trailing: const Icon(Icons.chevron_right),

                          /* =============================
                             CLICK → NAVIGATION
                          ============================= */
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