import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameRef<PixelAdventure> {
  JumpButton();

  final margin = 86;
  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    sprite = Sprite(
      game.images.fromCache('HUD/JumpButton.png'),
    );
    position = Vector2(
      game.size.x - margin - buttonSize,
      game.size.y - margin - buttonSize,
    );

    return super.onLoad();
  }
}
