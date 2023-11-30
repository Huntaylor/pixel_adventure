import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';

class Level extends World {
  final String levelName;
  late TiledComponent level;
  final Player player;

  Level({required this.levelName, required this.player});

  //onLoad only runs once as soon as we add Level to the game
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      '$levelName.tmx',
      Vector2.all(16),
    );

    add(level);

    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    for (final spawnPoint in spawnPointLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(
            spawnPoint.x,
            spawnPoint.y,
          );
          add(player);
          break;
        default:
      }
    }

    // super is refering to the 'extends', this will call all the other onLoad
    // events within the component we are extendings, in this case 'World'
    return super.onLoad();
  }
}
