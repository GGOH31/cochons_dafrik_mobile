import 'package:url_launcher/url_launcher.dart';

/// Ouvre une application de cartographie externe (Google Maps / Apple Maps / navigateur)
/// avec l'itinéraire vers les coordonnées GPS données.
Future<bool> openMapsDirections({
  required double latitude,
  required double longitude,
}) async {
  final googleMapsUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
  );

  if (await canLaunchUrl(googleMapsUrl)) {
    return launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  }

  return false;
}
