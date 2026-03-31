import 'dart:ui'; // Donne accès à PointerDeviceKind (utile pour le scroll souris/tactile)

import 'package:flutter/material.dart'; // Widgets Flutter
import 'package:intl/intl.dart'; // Formatage des dates
import 'package:provider/provider.dart'; // Accès aux services via Provider
import 'package:weather_app/models/forecast_item.dart'; // Modèle d'une prévision
import 'package:weather_app/models/weather.dart'; // Modèle météo actuelle
import 'package:weather_app/services/openweathermap_api.dart'; // Service d'appel API météo
import 'package:weather_app/ui/search_page.dart'; // Page de recherche

/* ============================================================
   PAGE METEO
   Cette page affiche :
   - la météo actuelle
   - les détails météo
   - les prévisions à venir
============================================================ */

class WeatherPage extends StatefulWidget {
  const WeatherPage({
    required this.locationName, // Nom de la ville affiché dans l'AppBar
    required this.latitude,     // Latitude utilisée pour appeler l'API
    required this.longitude,    // Longitude utilisée pour appeler l'API
    super.key,
  });

  final String locationName;
  final double latitude;
  final double longitude;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Formatteur pour la date principale (ex: mardi 31 mars)
  final DateFormat _dateFormatter = DateFormat.MMMMEEEEd();

  // Formatteur pour les cartes de prévision (ex: mar. 31/03 15:00)
  final DateFormat _forecastDateFormatter = DateFormat('E dd/MM HH:mm');

  // Contrôleur pour gérer le scroll horizontal des prévisions
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    // Toujours libérer un controller quand le widget est détruit
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On récupère le service API fourni plus haut par Provider
    // read() = on lit la valeur sans écouter des changements
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName), // Affiche le nom de la ville
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Ouvre la page de recherche
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
          ),
        ],
      ),

      // FutureBuilder n°1 :
      // attend le résultat de l'appel API pour la météo actuelle
      body: FutureBuilder<Weather>(
        future: openWeatherMapApi.getWeather(
          widget.latitude,
          widget.longitude,
        ),
        builder: (context, weatherSnapshot) {
          // Cas 1 : l'appel est encore en cours
          if (weatherSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Cas 2 : erreur pendant l'appel API
          if (weatherSnapshot.hasError) {
            return Center(
              child: Text(
                'Une erreur est survenue.\n${weatherSnapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Cas 3 : pas de donnée reçue
          if (!weatherSnapshot.hasData) {
            return const Center(
              child: Text('Aucune donnée météo disponible.'),
            );
          }

          // Cas 4 : on a bien reçu la météo actuelle
          final weather = weatherSnapshot.data!;

          // FutureBuilder n°2 :
          // attend le résultat de l'appel API pour les prévisions
          return FutureBuilder<List<ForecastItem>>(
            future: openWeatherMapApi.getForecast(
              widget.latitude,
              widget.longitude,
            ),
            builder: (context, forecastSnapshot) {
              // Si pas encore de données, on prend une liste vide par défaut
              final forecastItems = forecastSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Carte météo actuelle
                    _buildCurrentWeatherCard(
                      weather,
                      openWeatherMapApi,
                    ),
                    const SizedBox(height: 16),

                    // Carte des détails
                    _buildDetailsCard(weather),
                    const SizedBox(height: 16),

                    // Titre de la section prévisions
                    Text(
                      'Prévisions à venir',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    // Gestion des différents états des prévisions
                    if (forecastSnapshot.connectionState ==
                        ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (forecastSnapshot.hasError)
                      Text(
                        'Impossible de charger les prévisions.\n${forecastSnapshot.error}',
                        textAlign: TextAlign.center,
                      )
                    else if (forecastItems.isEmpty)
                      const Text('Aucune prévision disponible.')
                    else
                      // Scroll horizontal personnalisé pour les cartes de prévision
                      CustomScrollbarWithSingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: forecastItems.map((forecast) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildForecastCard(
                                forecast,
                                openWeatherMapApi,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /* ============================================================
     CARTE PRINCIPALE : METEO ACTUELLE
  ============================================================ */
  Widget _buildCurrentWeatherCard(
    Weather weather,
    OpenWeatherMapApi openWeatherMapApi,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Date actuelle formatée en français
            Text(
              _dateFormatter.format(weather.dateTime),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Condition météo principale (ex: Clear, Clouds, Rain)
            Text(
              weather.condition,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Description plus détaillée
            Text(
              weather.description,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Icône météo depuis l'API OpenWeatherMap
            Image.network(
              openWeatherMapApi.getIconUrl(weather.icon),
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),

            // Température actuelle
            Text(
              '${weather.temperature.toStringAsFixed(1)} °C',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Température ressentie
            Text(
              'Ressenti : ${weather.feelsLike.toStringAsFixed(1)} °C',
            ),
          ],
        ),
      ),
    );
  }

  /* ============================================================
     CARTE DETAILS
  ============================================================ */
  Widget _buildDetailsCard(Weather weather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Détails',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Chaque ligne affiche un couple label / valeur
            _buildDetailRow(
              'Température min',
              '${weather.tempMin.toStringAsFixed(1)} °C',
            ),
            _buildDetailRow(
              'Température max',
              '${weather.tempMax.toStringAsFixed(1)} °C',
            ),
            _buildDetailRow('Humidité', '${weather.humidity} %'),
            _buildDetailRow('Pression', '${weather.pressure} hPa'),
            _buildDetailRow(
              'Vent',
              '${weather.windSpeed.toStringAsFixed(1)} m/s',
            ),
            _buildDetailRow('Nuages', '${weather.cloudiness} %'),
            _buildDetailRow('Visibilité', '${weather.visibility} m'),
          ],
        ),
      ),
    );
  }

  /* ============================================================
     LIGNE DE DETAIL
     Evite de répéter plusieurs fois le même code
  ============================================================ */
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Le label prend l'espace disponible
          Expanded(
            child: Text(label),
          ),

          // La valeur est affichée en gras
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /* ============================================================
     CARTE DE PREVISION
     Une carte = une heure / date de prévision
  ============================================================ */
  Widget _buildForecastCard(
    ForecastItem forecast,
    OpenWeatherMapApi openWeatherMapApi,
  ) {
    return SizedBox(
      width: 170, // largeur fixe pour chaque carte
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Date de la prévision
              Text(
                _forecastDateFormatter.format(forecast.dateTime),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Icône météo
              Image.network(
                openWeatherMapApi.getIconUrl(forecast.icon),
                width: 70,
                height: 70,
              ),
              const SizedBox(height: 8),

              // Température prévue
              Text(
                '${forecast.temperature.toStringAsFixed(1)} °C',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // Description prévue
              Text(
                forecast.description,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   WIDGET DE SCROLL HORIZONTAL AVEC BARRE VISIBLE
   Sert à afficher proprement les cartes de prévision
============================================================ */

class CustomScrollbarWithSingleChildScrollView extends StatelessWidget {
  const CustomScrollbarWithSingleChildScrollView({
    required this.controller,       // Contrôle le scroll
    required this.child,            // Contenu à faire défiler
    required this.scrollDirection,  // Direction du scroll
    super.key,
  });

  final ScrollController controller;
  final Widget child;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const CustomScrollBehavior(), // Autorise plus de périphériques
      child: Scrollbar(
        controller: controller,
        thumbVisibility: true, // Barre visible en permanence
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: scrollDirection,
          child: child,
        ),
      ),
    );
  }
}

/* ============================================================
   COMPORTEMENT DE SCROLL PERSONNALISE
   Permet le drag avec souris, tactile, stylet, etc.
============================================================ */

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}