import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final featureFiles = Directory('lib/features')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);

  group('Clean Architecture boundaries', () {
    test('domain is framework and infrastructure independent', () {
      const forbiddenImports = <String>[
        'package:flutter/',
        'package:flutter_riverpod/',
        'package:http/',
        '/data/',
        '/presentation/',
      ];

      final violations = <String>[];
      for (final file in featureFiles.where(
        (file) => _normalized(file.path).contains('/domain/'),
      )) {
        final source = file.readAsStringSync();
        for (final forbiddenImport in forbiddenImports) {
          if (source.contains(forbiddenImport)) {
            violations.add('${file.path}: imports $forbiddenImport');
          }
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('presentation does not depend on data or repositories', () {
      const forbiddenImports = <String>['/data/', '/domain/repositories/'];
      final violations = <String>[];

      for (final file in featureFiles.where(
        (file) => _normalized(file.path).contains('/presentation/'),
      )) {
        final source = file.readAsStringSync();
        for (final forbiddenImport in forbiddenImports) {
          if (source.contains(forbiddenImport)) {
            violations.add('${file.path}: imports $forbiddenImport');
          }
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('data does not depend on presentation', () {
      final violations = featureFiles
          .where((file) => _normalized(file.path).contains('/data/'))
          .where((file) => file.readAsStringSync().contains('/presentation/'))
          .map((file) => '${file.path}: imports presentation')
          .toList(growable: false);

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('controllers live only in presentation', () {
      final violations = featureFiles
          .where((file) => file.path.endsWith('_controller.dart'))
          .where(
            (file) =>
                !_normalized(file.path).contains('/presentation/controller/'),
          )
          .map((file) => file.path)
          .toList(growable: false);

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('repository contracts live only in domain repositories', () {
      final violations = featureFiles
          .where((file) => file.path.endsWith('_repository.dart'))
          .where(
            (file) => !_normalized(file.path).contains('/domain/repositories/'),
          )
          .map((file) => file.path)
          .toList(growable: false);

      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });
}

String _normalized(String path) => path.replaceAll('\\', '/');
