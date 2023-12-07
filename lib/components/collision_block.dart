import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  bool isQuickSand;
  CollisionBlock({
    super.position,
    super.size,
    this.isPlatform = false,
    this.isQuickSand = false,
  });
}
