import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(
          position: position,
        );

  // Try to avoid hardcoding numbers, try to keep to using variables
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 460;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  Vector2 spawnPoint = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  bool isOnGround = false;
  bool isInQuicksand = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool gotAllFruit = false;
  bool hasReachedCheckpoint = false;
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

// Keep the main override methods together
  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    spawnPoint = Vector2(position.x, position.y);
    // debugMode = true;
    add(
      RectangleHitbox(
        position: Vector2(
          hitbox.offsetX,
          hitbox.offsetY,
        ),
        size: Vector2(
          hitbox.width,
          hitbox.height,
        ),
      ),
    );
    return super.onLoad();
  }

  //Update is called as many times as it can per frame.
  //Greater FPS, more updates
  @override
  void update(double dt) {
    gotAllFruit = game.collectedFruit == game.amountOfFruit;
    if (!gotHit && !hasReachedCheckpoint) {
      _updatePlayerMovement(dt);
      _updatePlayerState();
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!hasReachedCheckpoint) {
      if (other is Fruit) {
        game.lastFruitcollected = other;
        other.collidedWithPlayer();
      }
      if (other is Saw) _respawn();
      if (other is Checkpoint && !hasReachedCheckpoint && gotAllFruit) {
        _reachedCheckpoint();
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isInQuicksand ||
        hasJumped && isInQuicksand && isOnGround) {
      _playerJumpedInQuicksand(dt);
    } else if (hasJumped && isOnGround) {
      _playerJumped(dt);
    }

    // Prevents user to jump
    //when hasn't jumped in the air
    // if (velocity.y > _gravity) isOnGround = false;

    velocity.x = horizontalMovement * moveSpeed;
    // Delta time, dt, allows us to check how many times we have updated in a
    // second, then divide by the same amount to stay consistant
    position.x += velocity.x * dt;
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(
      state: 'Idle',
      amount: 11,
    );

    runningAnimation = _spriteAnimation(
      state: 'Run',
      amount: 12,
    );
    jumpingAnimation = _spriteAnimation(
      state: 'Jump',
      amount: 1,
    );
    fallingAnimation = _spriteAnimation(
      state: 'Fall',
      amount: 1,
    );
    hitAnimation = _spriteAnimation(
      state: 'Hit',
      amount: 7,
    )..loop = false;
    appearingAnimation = _spriteSpecialAnimation(
      state: 'Appearing',
      amount: 7,
    )..loop = false;
    disappearingAnimation = _spriteSpecialAnimation(
      state: 'Disappearing',
      amount: 7,
    )..loop = false;

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation({
    required String state,
    required int amount,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _spriteSpecialAnimation({
    required String state,
    required int amount,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    // Check if Falling, set to falling
    if (velocity.y > _gravity) playerState = PlayerState.falling;

    // Check if Jumping, set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    moveSpeed = 100;
    for (final block in collisionBlocks) {
      if (!block.isPlatform && !block.isQuickSand) {
        if (checkCollisions(
          player: this,
          block: block,
        )) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
          }
        }
      } else if (block.isQuickSand) {
        if (checkCollisions(
          player: this,
          block: block,
        )) {
          moveSpeed = moveSpeed / 2;

          if (velocity.x > 0) {
            velocity.x = 0;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollisions(player: this, block: block)) {
          if (velocity.y > 0) {
            velocity.y = 0;

            //Shouldn't this be Height instead of width?  Yep, I was right!
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else if (block.isQuickSand) {
        if (checkCollisions(player: this, block: block)) {
          isInQuicksand = true;
          if (velocity.y > 0) {
            velocity.y = 0;
          }
        } else {
          isInQuicksand = false;
        }
      } else {
        if (checkCollisions(player: this, block: block)) {
          if (velocity.y > 0) {
            velocity.y = 0;

            //Shouldn't this be Height instead of width? Yep, I was right!
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            isInQuicksand = false;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _playerJumped(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void _playerJumpedInQuicksand(double dt) {
    velocity.y = -_jumpForce / 4;
    position.y += velocity.y * dt;
  }

  void _respawn() {
    gotHit = true;
    current = PlayerState.hit;
    final hitAnimationTicker = animationTickers![PlayerState.hit]!;
    hitAnimationTicker.completed.whenComplete(() {
      scale.x = 1;
      position = spawnPoint - Vector2.all(32);
      current = PlayerState.appearing;
      hitAnimationTicker.reset();
      final apearingAnimationTicker = animationTickers![PlayerState.appearing]!;
      apearingAnimationTicker.completed.whenComplete(() {
        velocity = Vector2.zero();
        position = spawnPoint;
        _updatePlayerState();
        apearingAnimationTicker.reset();
        gotHit = false;
      });
    });
  }

  void _reachedCheckpoint() {
    hasReachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position - Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    final disappearAnimationTicker =
        animationTickers![PlayerState.disappearing]!;
    disappearAnimationTicker.completed.whenComplete(() {
      hasReachedCheckpoint = false;
      removeFromParent();
      // position = Vector2.all(-640);

      const waitToChangeDuration = Duration(seconds: 3);
      Future.delayed(waitToChangeDuration).whenComplete(
        () => game.loadNextLevel(),
      );
      disappearAnimationTicker.reset();
    });
  }
}
