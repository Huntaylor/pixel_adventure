import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World {
  late TiledComponent level;

  //onLoad only runs once as soon as we add Level to the game
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      'level-01.tmx',
      Vector2.all(16),
    );

    add(level);

    // super is refering to the 'extends', this will call all the other onLoad
    // events within the component we are extendings, in this case 'World'
    return super.onLoad();
  }
}
