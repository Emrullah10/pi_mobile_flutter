import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';

class DiscoveryService {
  /// whisperpi.local adresini mDNS ile çözmeye çalışır.
  /// Başarılı olursa IP'yi döner, bulamazsa null.
  Future<String?> discoverPiIp({
    String hostname = 'whisperpi.local',
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final client = MDnsClient();
    try {
      await client.start();
      // A kaydını sorgula (IPv4)
      final completer = Completer<String?>();
      final sub = client
          .lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(hostname),
          )
          .listen(
        (record) {
          if (!completer.isCompleted) {
            completer.complete(record.address.address);
          }
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(null);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(null);
        },
      );

      final result = await completer.future.timeout(timeout, onTimeout: () => null);
      await sub.cancel();
      return result;
    } catch (_) {
      return null;
    } finally {
      client.stop();
    }
  }
}
