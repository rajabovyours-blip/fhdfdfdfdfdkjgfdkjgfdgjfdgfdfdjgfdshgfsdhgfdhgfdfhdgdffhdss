// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final configStr = File('.dart_tool/package_config.json').readAsStringSync();
  final config = jsonDecode(configStr);
  final packages = config['packages'] as List;

  for (var pkg in packages) {
    final rootUri = pkg['rootUri'] as String;
    if (rootUri.startsWith('file:///')) {
      final path = Uri.parse(rootUri).toFilePath();
      final dir = Directory(path);
      if (dir.existsSync()) {
        for (var entity in dir.listSync(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            try {
              final content = entity.readAsStringSync();
              if (content.contains('toARGB32')) {
                print('FOUND in ${pkg["name"]}: ${entity.path}');
              }
            } catch (e) {
              // ignore
            }
          }
        }
      }
    }
  }
}
