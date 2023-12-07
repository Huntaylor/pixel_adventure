import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({
    super.position,
    super.size,
  });

  bool hasReachedCheckpoint = false;
  final String noFlagName =
      'Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png';
  final String flagOutName =
      'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png';
  final String idleFlagName =
      'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png';

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(
        position: Vector2(
          18,
          56,
        ),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive,
      ),
    );

    animation = flagSpriteAnimation(name: noFlagName, amount: 1, stepTime: 1);
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !hasReachedCheckpoint) {
      _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    hasReachedCheckpoint = true;
    animation = flagSpriteAnimation(
      name: flagOutName,
      amount: 26,
      stepTime: 0.05,
    )..loop = false;
    animationTicker!.completed.whenComplete(
      () => animation = flagSpriteAnimation(
        name: idleFlagName,
        amount: 10,
        stepTime: 0.05,
      ),
    );
  }

  SpriteAnimation flagSpriteAnimation({
    required String name,
    required int amount,
    required double stepTime,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(name),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );
  }
}
