import 'dart:io';

import 'package:yaml_modify/yaml_modify.dart';

main(List<String> args) {
  if (args.isEmpty) {
    throw ArgumentError('No arguments given');
  }
  if (args.length != 3 && args.length != 2) {
    throw ArgumentError('Not all arguments given');
  }

  String pubspecLocation = args[0];
  String buildNumber = args[1];
  String? appVersion;
  if (args.length == 3) {
    appVersion = args[2];
  }

  File file = File(pubspecLocation);
  final yaml = loadYaml(file.readAsStringSync());

  final modifiable = getModifiableNode(yaml);
  final version = (modifiable['version'] as String).split("+");
  if (appVersion != null) {
    modifiable['version'] = "${appVersion}+${buildNumber}";
  } else {
    appVersion = version[0];
    modifiable['version'] = "${version[0]}+${buildNumber}";
  }

  final strYaml = toYamlString(modifiable);
  File(pubspecLocation).writeAsStringSync(strYaml);

  stdout.writeln("APP_VERSION: $appVersion");
  stdout.writeln("APP_BUILD_NUMBER: $buildNumber");
  stdout.writeln("APP_VERSION_STRING: ${modifiable['version']}");

  return 0;
}
