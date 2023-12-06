import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';

class Level extends World with HasGameRef {
  final String levelName;
  late TiledComponent level;
  final Player player;
  List<CollisionBlock> collisionBlock = [];

  Level({required this.levelName, required this.player});

  //onLoad only runs once as soon as we add Level to the game
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      '$levelName.tmx',
      Vector2.all(16),
    );

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    // super is refering to the 'extends', this will call all the other onLoad
    // events within the component we are extendings, in this case 'World'
    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    const tileSize = 64;

    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      for (double y = 0; y < game.size.y / numTilesY; y++) {
        for (double x = 0; x < /* game.size.x / */ numTilesX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
            position: Vector2(x * tileSize - tileSize, y * tileSize - tileSize),
          );
          add(backgroundTile);
        }
      }
    }
  }

  void _spawningObjects() {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(
              spawnPoint.x,
              spawnPoint.y,
            );
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
            );
            add(fruit);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(
                collision.x,
                collision.y,
              ),
              size: Vector2(
                collision.width,
                collision.height,
              ),
              isPlatform: true,
            );
            collisionBlock.add(platform);
            add(platform);
            break;
          case 'Quicksand':
            final quicksand = CollisionBlock(
              position: Vector2(
                collision.x,
                collision.y,
              ),
              size: Vector2(
                collision.width,
                collision.height,
              ),
              isQuickSand: true,
            );
            collisionBlock.add(quicksand);
            add(quicksand);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(
                collision.x,
                collision.y,
              ),
              size: Vector2(
                collision.width,
                collision.height,
              ),
            );
            collisionBlock.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlock;
  }
}
