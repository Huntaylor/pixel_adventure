import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  // @override
  // Color backgroundColor() => const Color(0x0FF21F30);

  // late CameraComponent cam;

  Player player = Player(
    character: 'Mask Dude',
  );
  JumpButton jumpButton = JumpButton();
  late JoystickComponent joystick;
  bool showControls = true;
  List<String> levelNames = ['Level-01', 'Level-02'];
  int currentLevelIndex = 0;
  int amountOfFruit = 0;
  int collectedFruit = 0;
  Fruit lastFruitcollected = Fruit();

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache, not a good idea if you have a lot of images
    await images.loadAllImages();
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
      position: Vector2.all(0),
    );

    _loadLevel();

    // for some reason, the joystick was behind the background. Not sure why yet
    // had to change the joystick to be part of the HUD
    // addJoystick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
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

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      //no more levels
    }
  }

  void _loadLevel() {
    Future.delayed(
        const Duration(
          seconds: 1,
        ), () {
      Level world = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );

      camera = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360,
        hudComponents: [
          // GameHUD(),
          if (showControls) joystick,
          if (showControls) jumpButton,
        ],
      );

      //Gives me the appropriate game size with Aspect ratio.
      //There has to be a better way to get it though
      double screenWidth = jumpButton.game.size.x;
      double screenHeight = jumpButton.game.size.y;
      const margin = 32;
      const buttonSize = 64;
      const sizeDiff = 8;

      double joystickX = (screenWidth / 6) - buttonSize + 6;
      double joystickY = screenHeight - margin - sizeDiff;

      joystick.position = Vector2(
        joystickX,
        joystickY,
      );

      camera.viewfinder.anchor = Anchor.topLeft;

      addAll(
        [camera, world],
      );
    });
  }
}
