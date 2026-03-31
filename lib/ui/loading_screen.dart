import 'package:flutter/material.dart'; // Widgets Flutter
import 'package:geolocator/geolocator.dart'; // Type Position
import 'package:provider/provider.dart'; // Accès aux services via Provider
import 'package:weather_app/services/geolocation_service.dart'; // Service GPS
import 'package:weather_app/services/openweathermap_api.dart'; // Service API météo
import 'package:weather_app/ui/search_page.dart'; // Page de recherche
import 'package:weather_app/ui/weather_page.dart'; // Page météo

/* ============================================================
   ECRAN DE CHARGEMENT
   Cette page est affichée au démarrage de l'application.
   Son rôle :
   - récupérer la position de l'utilisateur
   - essayer de trouver le nom du lieu
   - rediriger vers la page météo
   - sinon rediriger vers la page de recherche
============================================================ */

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // initState est appelé une seule fois quand le widget est créé.
    // On en profite pour lancer immédiatement le chargement.
    getLocationData();
  }

  /* ============================================================
     RECUPERATION DE LA LOCALISATION
  ============================================================ */
  Future<void> getLocationData() async {
    // On récupère les services fournis par Provider
    final geolocationService = context.read<GeolocationService>();
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    // Demande la position actuelle de l'utilisateur
    final Position? position = await geolocationService.getCurrentPosition();

    // mounted permet de vérifier que le widget est encore présent dans l'arbre
    // avant d'utiliser context ou Navigator après un await.
    if (!mounted) {
      return;
    }

    // Si on a bien obtenu une position GPS
    if (position != null) {
      // Valeur par défaut si on ne parvient pas à obtenir le vrai nom du lieu
      String locationName = 'Ma position';

      try {
        // Tente de convertir latitude/longitude en nom de lieu lisible
        locationName = await openWeatherMapApi.getLocationNameFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (_) {
        // Si cette étape échoue, on garde simplement "Ma position"
      }

      // Deuxième vérification de sécurité après un await
      if (!mounted) {
        return;
      }

      // Remplace l'écran de chargement par la page météo
      // pushReplacement = on ne garde pas LoadingScreen dans l'historique
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherPage(
            locationName: locationName,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        ),
      );
    } else {
      // Si aucune position n'a pu être récupérée,
      // on redirige vers la page de recherche manuelle
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SearchPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pendant le chargement, on affiche simplement un spinner
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}