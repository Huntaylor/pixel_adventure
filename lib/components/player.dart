import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, running, jumping, falling }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  String character;
  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(position: position);

  // Try to avoid hardcoding numbers, try to keep to using variables
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 460;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  bool isOnGround = false;
  bool hasJumped = false;

// Keep the main override methods together
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    return super.onLoad();
  }

  //Update is called as many times as it can per frame.
  //Greater FPS, more updates
  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    _updatePlayerState();
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
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

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJumped(dt);

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

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.jumping: jumpingAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(
      {required String state, required int amount}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
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
            position.x = block.x - width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + width;
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

            //Shouldn't this be Height instead of width?
            position.y = block.y - width;
            isOnGround = true;
            break;
          }
        }
      } else if (block.isQuickSand) {
        if (checkCollisions(player: this, block: block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
          }
        }
      } else {
        if (checkCollisions(player: this, block: block)) {
          if (velocity.y > 0) {
            velocity.y = 0;

            //Shouldn't this be Height instead of width?
            position.y = block.y - width;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height;
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
}
