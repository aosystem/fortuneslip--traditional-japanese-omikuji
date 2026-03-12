
import 'package:just_audio/just_audio.dart';

import 'package:fortuneslip/model.dart';

class AudioPlay {
  late AudioPlayer _audioPlayer;

  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
  }

  void play() {
    if (Model.soundVolume == 0) {
      return;
    }
    _audioPlayer = AudioPlayer();
    _audioPlayer.setAsset('assets/sound/switch.wav');
    _audioPlayer.setVolume(Model.soundVolume);
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.play();
  }

}
