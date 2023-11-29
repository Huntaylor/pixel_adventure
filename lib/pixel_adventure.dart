import 'dart:async';

import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame {
  @override
  FutureOr<void> onLoad() {
    add(Level());
    return super.onLoad();
  }
}
