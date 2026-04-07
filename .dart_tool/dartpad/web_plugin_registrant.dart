// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:speech_to_text/speech_to_text_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  FirebaseCoreWeb.registerWith(registrar);
  FlutterTtsPlugin.registerWith(registrar);
  GoogleMapsPlugin.registerWith(registrar);
  SpeechToTextPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
