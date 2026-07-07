import 'package:shared_preferences/shared_preferences.dart';

class ServerConfig {
  ServerConfig._();

  static const String _key = 'server_base_url';
  static const String defaultUrl = 'http://192.168.1.39:3000';

  static String _current = defaultUrl;

  static String get baseUrl => _current;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _current = prefs.getString(_key) ?? defaultUrl;
  }

  static Future<void> setBaseUrl(String input) async {
    final normalized = _normalize(input);
    _current = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, normalized);
  }

  // "192.168.1.39" / "192.168.1.39:3000" / "http://x:3000" → "http://host:port"
  static String _normalize(String input) {
    var s = input.trim();
    if (s.isEmpty) return defaultUrl;

    // http:// veya https:// yoksa ekle
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'http://$s';
    }

    // Sonundaki / temizle
    if (s.endsWith('/')) s = s.substring(0, s.length - 1);

    // Port yoksa :3000 ekle.
    // NOT: Uri.port, port belirtilmese bile şemaya göre 80/443 döndürür
    // (0 değil). Bu yüzden host kısmında ':' olup olmadığına bakıyoruz.
    final uri = Uri.tryParse(s);
    if (uri != null && uri.host.isNotEmpty && !uri.hasPort) {
      s = '${uri.scheme}://${uri.host}:3000${uri.path}';
    }

    return s;
  }
}
