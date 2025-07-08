import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playClick() async {
    await _player.play(AssetSource('sounds/StarCollect.wav'));
  }
} 