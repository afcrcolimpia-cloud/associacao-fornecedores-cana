import 'package:url_launcher/url_launcher.dart';

class FileUtils {
  /// Tenta abrir uma URL pública em um browser externo.
  /// Retorna true se conseguiu abrir, false caso contrário.
  static Future<bool> openFile(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
