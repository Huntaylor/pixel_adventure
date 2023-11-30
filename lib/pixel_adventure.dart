import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x0FF21F30);

  late final CameraComponent cam;

  @override
  final world = Level(
    levelName: 'Level-02',
  );

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache, not idea if you have a lot of images
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
    return super.onLoad();
  }
}
