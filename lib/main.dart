import 'package:flutter/material.dart'; // Widgets Flutter
import 'package:intl/date_symbol_data_local.dart'; // Gestion formats de dates locales
import 'package:intl/intl.dart'; // Formatage de dates (ex: français)
import 'package:provider/provider.dart'; // Gestion des dépendances (injection)
import 'package:weather_app/config.dart'; // Contient la clé API
import 'package:weather_app/services/geolocation_service.dart'; // Service GPS
import 'package:weather_app/services/openweathermap_api.dart'; // Service API météo
import 'package:weather_app/ui/loading_screen.dart'; // Première page affichée

/* ============================================================
   POINT D’ENTRÉE DE L’APPLICATION
============================================================ */

void main() async {
  // Permet d’utiliser du code async avant runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Définit la langue par défaut pour les dates
  Intl.defaultLocale = 'fr_FR';

  // Initialise le format des dates en français
  await initializeDateFormatting('fr_FR');

  // Lance l’application
  runApp(const WeatherApp());
}

/* ============================================================
   APPLICATION PRINCIPALE
============================================================ */

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      // Permet d’injecter plusieurs services dans toute l’app
      providers: [

        // Fournit l’API météo partout dans l’application
        Provider(
          create: (_) => OpenWeatherMapApi(apiKey: openWeatherMapApiKey),
        ),

        // Fournit le service de géolocalisation
        Provider(
          create: (_) => GeolocationService(),
        ),
      ],

      // Configuration globale de l'application
      child: MaterialApp(
        title: 'Weather App',

        // Thème sombre
        theme: ThemeData.dark(),

        // Supprime le bandeau debug
        debugShowCheckedModeBanner: false,

        // Page de démarrage (chargement + redirection)
        home: const LoadingScreen(),
      ),
    );
  }
}