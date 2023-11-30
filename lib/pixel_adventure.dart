import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0x0FF21F30);

  late final CameraComponent cam;
  Player player = Player(
    character: 'Mask Dude',
  );
  late JoystickComponent joystick;
  bool showJoystick = false;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache, not idea if you have a lot of images
    await images.loadAllImages();

    @override
    final world = Level(
      levelName: 'Level-02',
      player: player,
    )..priority = 0;

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
        left: 8,
        //Don't think this should be this big...
        bottom: 320,
      ),
    );

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
      // hudComponents: [joystick],
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

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
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.idle:
        player.horizontalMovement = 0;
        break;
      default:
        player.horizontalMovement = 0;
    }
  }

  void addJoystick() {
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
        left: 32,
        bottom: 32,
      ),
    );

    add(joystick);
  }
}
