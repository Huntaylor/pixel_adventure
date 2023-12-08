import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  JumpButton({super.position});

  @override
  FutureOr<void> onLoad() {
    const margin = 32;
    const buttonSize = 64;
    const sizeDiff = 24;
    sprite = Sprite(
      game.images.fromCache('HUD/JumpButton.png'),
    );
    position = Vector2(
      game.size.x - margin - buttonSize + (sizeDiff / 2),
      game.size.y - margin - buttonSize + sizeDiff,
    );
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
