import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class GameHUD extends PositionComponent with HasGameRef<PixelAdventure> {
  GameHUD({
    positionType = PositionType.viewport,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  });

  late TextComponent _scoreTextComponent;

  @override
  FutureOr<void> onLoad() {
    _scoreTextComponent = TextComponent(
      text: '${game.collectedFruit}/${game.amountOfFruit}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Color.fromRGBO(255, 0, 0, 1),
        ),
      ),
      position: Vector2.all(16),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.collectedFruit}/${game.amountOfFruit}';
  }
}
