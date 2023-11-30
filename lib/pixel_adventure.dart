import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0x0FF21F30);

  late final CameraComponent cam;
  Player player = Player(
    character: 'Mask Dude',
  );
  late JoystickComponent joystick;
  bool showJoystick = true;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache, not idea if you have a lot of images
    await images.loadAllImages();

    @override
    final world = Level(
      levelName: 'Level-01',
      player: player,
    );

    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      knobRadius: 32,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(
        left: 16,
        bottom: 64,
      ),
    );

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
      hudComponents: [joystick],
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    await addAll([cam, world]);
    // addJoystick();

    // for some reason, the joystick was behind the background. Not sure why yet
    // had to change the joystick to be part of the HUD
    // addJoystick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.downLeft:
      case JoystickDirection.upLeft:
        player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
        player.playerDirection = PlayerDirection.right;
        break;
      case JoystickDirection.idle:
        player.playerDirection = PlayerDirection.none;
        break;
      default:
        player.playerDirection = PlayerDirection.none;
    }
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 5,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      knobRadius: 32,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(
        left: 32,
        bottom: 32,
      ),
    );

    add(joystick);
  }
}
