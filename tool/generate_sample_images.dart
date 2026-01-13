import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

// Line thickness for clearer coloring boundaries
const int lineThickness = 4;

void main() async {
  print('Generating sample coloring images with clear lines...');

  // Create directories
  final categories = ['animals', 'plants', 'vehicles', 'characters', 'nature', 'food'];
  for (final cat in categories) {
    final dir = Directory('assets/images/categories/$cat');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  // Animals (8 images)
  await generateAndSave('assets/images/categories/animals/cat.png', generateCat());
  await generateAndSave('assets/images/categories/animals/dog.png', generateDog());
  await generateAndSave('assets/images/categories/animals/bird.png', generateBird());
  await generateAndSave('assets/images/categories/animals/fish.png', generateFish());
  await generateAndSave('assets/images/categories/animals/butterfly.png', generateButterfly());
  await generateAndSave('assets/images/categories/animals/rabbit.png', generateRabbit());
  await generateAndSave('assets/images/categories/animals/elephant.png', generateElephant());
  await generateAndSave('assets/images/categories/animals/turtle.png', generateTurtle());

  // Plants (7 images)
  await generateAndSave('assets/images/categories/plants/flower.png', generateFlower());
  await generateAndSave('assets/images/categories/plants/tree.png', generateTree());
  await generateAndSave('assets/images/categories/plants/rose.png', generateRose());
  await generateAndSave('assets/images/categories/plants/tulip.png', generateTulip());
  await generateAndSave('assets/images/categories/plants/sunflower.png', generateSunflower());
  await generateAndSave('assets/images/categories/plants/cactus.png', generateCactus());
  await generateAndSave('assets/images/categories/plants/mushroom.png', generateMushroom());

  // Vehicles (8 images)
  await generateAndSave('assets/images/categories/vehicles/car.png', generateCar());
  await generateAndSave('assets/images/categories/vehicles/plane.png', generatePlane());
  await generateAndSave('assets/images/categories/vehicles/boat.png', generateBoat());
  await generateAndSave('assets/images/categories/vehicles/train.png', generateTrain());
  await generateAndSave('assets/images/categories/vehicles/helicopter.png', generateHelicopter());
  await generateAndSave('assets/images/categories/vehicles/rocket.png', generateRocket());
  await generateAndSave('assets/images/categories/vehicles/bicycle.png', generateBicycle());
  await generateAndSave('assets/images/categories/vehicles/bus.png', generateBus());

  // Characters (7 images)
  await generateAndSave('assets/images/categories/characters/princess.png', generatePrincess());
  await generateAndSave('assets/images/categories/characters/superhero.png', generateSuperhero());
  await generateAndSave('assets/images/categories/characters/robot.png', generateRobot());
  await generateAndSave('assets/images/categories/characters/pirate.png', generatePirate());
  await generateAndSave('assets/images/categories/characters/fairy.png', generateFairy());
  await generateAndSave('assets/images/categories/characters/knight.png', generateKnight());
  await generateAndSave('assets/images/categories/characters/mermaid.png', generateMermaid());

  // Nature (8 images)
  await generateAndSave('assets/images/categories/nature/sun.png', generateSun());
  await generateAndSave('assets/images/categories/nature/rainbow.png', generateRainbow());
  await generateAndSave('assets/images/categories/nature/cloud.png', generateCloud());
  await generateAndSave('assets/images/categories/nature/star.png', generateStar());
  await generateAndSave('assets/images/categories/nature/moon.png', generateMoon());
  await generateAndSave('assets/images/categories/nature/mountain.png', generateMountain());
  await generateAndSave('assets/images/categories/nature/wave.png', generateWave());
  await generateAndSave('assets/images/categories/nature/snowflake.png', generateSnowflake());

  // Food (8 images)
  await generateAndSave('assets/images/categories/food/apple.png', generateApple());
  await generateAndSave('assets/images/categories/food/icecream.png', generateIcecream());
  await generateAndSave('assets/images/categories/food/cupcake.png', generateCupcake());
  await generateAndSave('assets/images/categories/food/pizza.png', generatePizza());
  await generateAndSave('assets/images/categories/food/watermelon.png', generateWatermelon());
  await generateAndSave('assets/images/categories/food/cookie.png', generateCookie());
  await generateAndSave('assets/images/categories/food/lollipop.png', generateLollipop());
  await generateAndSave('assets/images/categories/food/banana.png', generateBanana());

  print('Done! Generated ${46} sample images.');
}

Future<void> generateAndSave(String path, Uint8List data) async {
  final file = File(path);
  await file.writeAsBytes(data);
  print('Generated: $path');
}

// ==================== ANIMALS ====================

Uint8List generateCat() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawCircleThick(image, cx, cy, 90, black);

  // Ears
  drawTriangleThick(image, cx - 60, cy - 60, cx - 95, cy - 130, cx - 25, cy - 90, black);
  drawTriangleThick(image, cx + 60, cy - 60, cx + 95, cy - 130, cx + 25, cy - 90, black);

  // Inner ears
  drawTriangleThick(image, cx - 55, cy - 70, cx - 80, cy - 110, cx - 35, cy - 85, black);
  drawTriangleThick(image, cx + 55, cy - 70, cx + 80, cy - 110, cx + 35, cy - 85, black);

  // Eyes
  drawOvalThick(image, cx - 30, cy - 15, 18, 25, black);
  drawOvalThick(image, cx + 30, cy - 15, 18, 25, black);

  // Nose
  drawTriangleThick(image, cx - 12, cy + 25, cx + 12, cy + 25, cx, cy + 40, black);

  // Mouth
  drawLineThick(image, cx, cy + 40, cx, cy + 55, black);
  drawLineThick(image, cx - 25, cy + 65, cx, cy + 55, black);
  drawLineThick(image, cx + 25, cy + 65, cx, cy + 55, black);

  // Whiskers
  drawLineThick(image, cx - 35, cy + 35, cx - 100, cy + 25, black);
  drawLineThick(image, cx - 35, cy + 45, cx - 100, cy + 50, black);
  drawLineThick(image, cx + 35, cy + 35, cx + 100, cy + 25, black);
  drawLineThick(image, cx + 35, cy + 45, cx + 100, cy + 50, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateDog() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 190;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawOvalThick(image, cx, cy, 85, 100, black);

  // Ears (floppy)
  drawOvalThick(image, cx - 80, cy - 20, 30, 65, black);
  drawOvalThick(image, cx + 80, cy - 20, 30, 65, black);

  // Eyes
  drawCircleThick(image, cx - 28, cy - 25, 18, black);
  drawCircleThick(image, cx + 28, cy - 25, 18, black);

  // Eye pupils
  drawCircleThick(image, cx - 28, cy - 25, 8, black);
  drawCircleThick(image, cx + 28, cy - 25, 8, black);

  // Nose
  drawOvalThick(image, cx, cy + 25, 22, 18, black);

  // Tongue
  drawOvalThick(image, cx, cy + 70, 18, 35, black);

  // Collar
  drawLineThick(image, cx - 60, cy + 90, cx + 60, cy + 90, black);
  drawCircleThick(image, cx, cy + 105, 12, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateBird() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 180, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Body
  drawOvalThick(image, cx, cy, 75, 55, black);

  // Head
  drawCircleThick(image, cx + 75, cy - 25, 40, black);

  // Beak
  drawTriangleThick(image, cx + 105, cy - 25, cx + 150, cy - 15, cx + 105, cy - 5, black);

  // Eye
  drawCircleThick(image, cx + 85, cy - 35, 10, black);

  // Wing
  drawOvalThick(image, cx - 15, cy + 5, 45, 25, black);
  drawLineThick(image, cx - 50, cy + 15, cx + 20, cy - 10, black);

  // Tail
  drawTriangleThick(image, cx - 75, cy - 15, cx - 130, cy - 45, cx - 75, cy + 25, black);
  drawLineThick(image, cx - 75, cy, cx - 120, cy - 20, black);

  // Legs
  drawLineThick(image, cx - 15, cy + 55, cx - 25, cy + 100, black);
  drawLineThick(image, cx + 15, cy + 55, cx + 5, cy + 100, black);
  drawLineThick(image, cx - 40, cy + 100, cx - 10, cy + 100, black);
  drawLineThick(image, cx - 10, cy + 100, cx + 20, cy + 100, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateFish() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Body
  drawOvalThick(image, cx, cy, 110, 55, black);

  // Tail
  drawTriangleThick(image, cx - 110, cy, cx - 165, cy - 55, cx - 165, cy + 55, black);

  // Eye
  drawCircleThick(image, cx + 50, cy - 12, 18, black);
  drawCircleThick(image, cx + 50, cy - 12, 8, black);

  // Fins
  drawTriangleThick(image, cx + 5, cy - 55, cx - 25, cy - 100, cx + 35, cy - 100, black);
  drawTriangleThick(image, cx - 25, cy + 55, cx - 55, cy + 90, cx + 5, cy + 55, black);

  // Scales (curved lines)
  for (int i = 0; i < 4; i++) {
    drawArcThick(image, cx - 55 + i * 30, cy, 22, black);
  }

  // Mouth
  drawLineThick(image, cx + 100, cy, cx + 85, cy + 10, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateButterfly() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Body
  drawOvalThick(image, cx, cy, 12, 75, black);

  // Head
  drawCircleThick(image, cx, cy - 95, 22, black);

  // Antennae
  drawLineThick(image, cx - 12, cy - 115, cx - 35, cy - 155, black);
  drawLineThick(image, cx + 12, cy - 115, cx + 35, cy - 155, black);
  drawCircleThick(image, cx - 35, cy - 155, 6, black);
  drawCircleThick(image, cx + 35, cy - 155, 6, black);

  // Upper wings
  drawOvalThick(image, cx - 70, cy - 35, 60, 50, black);
  drawOvalThick(image, cx + 70, cy - 35, 60, 50, black);

  // Lower wings
  drawOvalThick(image, cx - 55, cy + 35, 50, 40, black);
  drawOvalThick(image, cx + 55, cy + 35, 50, 40, black);

  // Wing patterns
  drawCircleThick(image, cx - 70, cy - 35, 25, black);
  drawCircleThick(image, cx + 70, cy - 35, 25, black);
  drawCircleThick(image, cx - 55, cy + 35, 18, black);
  drawCircleThick(image, cx + 55, cy + 35, 18, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateRabbit() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 220;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawCircleThick(image, cx, cy, 80, black);

  // Ears
  drawOvalThick(image, cx - 45, cy - 130, 25, 70, black);
  drawOvalThick(image, cx + 45, cy - 130, 25, 70, black);
  // Inner ears
  drawOvalThick(image, cx - 45, cy - 130, 12, 50, black);
  drawOvalThick(image, cx + 45, cy - 130, 12, 50, black);

  // Eyes
  drawCircleThick(image, cx - 30, cy - 15, 15, black);
  drawCircleThick(image, cx + 30, cy - 15, 15, black);

  // Nose
  drawOvalThick(image, cx, cy + 25, 15, 12, black);

  // Mouth
  drawLineThick(image, cx, cy + 37, cx, cy + 50, black);
  drawLineThick(image, cx - 20, cy + 55, cx, cy + 50, black);
  drawLineThick(image, cx + 20, cy + 55, cx, cy + 50, black);

  // Whiskers
  drawLineThick(image, cx - 30, cy + 30, cx - 80, cy + 20, black);
  drawLineThick(image, cx - 30, cy + 40, cx - 80, cy + 45, black);
  drawLineThick(image, cx + 30, cy + 30, cx + 80, cy + 20, black);
  drawLineThick(image, cx + 30, cy + 40, cx + 80, cy + 45, black);

  // Teeth
  drawRectThick(image, cx - 8, cy + 50, cx + 8, cy + 65, black);
  drawLineThick(image, cx, cy + 50, cx, cy + 65, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateElephant() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 180;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawCircleThick(image, cx, cy, 85, black);

  // Ears
  drawOvalThick(image, cx - 110, cy, 50, 70, black);
  drawOvalThick(image, cx + 110, cy, 50, 70, black);

  // Trunk
  drawLineThick(image, cx - 20, cy + 50, cx - 30, cy + 150, black);
  drawLineThick(image, cx + 20, cy + 50, cx + 10, cy + 150, black);
  drawArcThick(image, cx - 10, cy + 150, 20, black);

  // Eyes
  drawCircleThick(image, cx - 30, cy - 20, 12, black);
  drawCircleThick(image, cx + 30, cy - 20, 12, black);

  // Tusks
  drawLineThick(image, cx - 50, cy + 40, cx - 80, cy + 100, black);
  drawLineThick(image, cx + 50, cy + 40, cx + 80, cy + 100, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateTurtle() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Shell
  drawOvalThick(image, cx, cy, 100, 70, black);

  // Shell pattern
  drawCircleThick(image, cx, cy, 35, black);
  for (int i = 0; i < 6; i++) {
    final angle = i * math.pi / 3;
    final px = cx + (60 * math.cos(angle)).round();
    final py = cy + (42 * math.sin(angle)).round();
    drawCircleThick(image, px, py, 22, black);
  }

  // Head
  drawOvalThick(image, cx + 110, cy, 30, 25, black);
  drawCircleThick(image, cx + 120, cy - 8, 6, black);

  // Legs
  drawOvalThick(image, cx - 70, cy + 50, 25, 18, black);
  drawOvalThick(image, cx + 70, cy + 50, 25, 18, black);
  drawOvalThick(image, cx - 70, cy - 50, 25, 18, black);
  drawOvalThick(image, cx + 40, cy - 55, 25, 18, black);

  // Tail
  drawTriangleThick(image, cx - 100, cy, cx - 135, cy - 10, cx - 135, cy + 10, black);

  return Uint8List.fromList(img.encodePng(image));
}

// ==================== PLANTS ====================

Uint8List generateFlower() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 150;
  final black = img.ColorRgb8(0, 0, 0);

  // Petals
  for (int i = 0; i < 8; i++) {
    final angle = i * math.pi / 4;
    final px = cx + (55 * math.cos(angle)).round();
    final py = cy + (55 * math.sin(angle)).round();
    drawCircleThick(image, px, py, 35, black);
  }

  // Center
  drawCircleThick(image, cx, cy, 28, black);

  // Stem
  drawLineThick(image, cx - 2, cy + 60, cx - 2, 350, black);
  drawLineThick(image, cx + 2, cy + 60, cx + 2, 350, black);

  // Leaves
  drawOvalThick(image, cx - 40, 270, 32, 15, black);
  drawOvalThick(image, cx + 40, 310, 32, 15, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateTree() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Trunk
  drawRectThick(image, cx - 30, 240, cx + 30, 380, black);

  // Foliage (3 triangles)
  drawTriangleThick(image, cx - 105, 250, cx + 105, 250, cx, 145, black);
  drawTriangleThick(image, cx - 85, 190, cx + 85, 190, cx, 95, black);
  drawTriangleThick(image, cx - 65, 140, cx + 65, 140, cx, 55, black);

  // Trunk lines
  drawLineThick(image, cx - 10, 260, cx - 10, 370, black);
  drawLineThick(image, cx + 10, 280, cx + 10, 360, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateRose() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 140;
  final black = img.ColorRgb8(0, 0, 0);

  // Rose petals (spiraling circles)
  drawCircleThick(image, cx, cy, 22, black);
  drawCircleThick(image, cx - 28, cy - 12, 28, black);
  drawCircleThick(image, cx + 28, cy - 12, 28, black);
  drawCircleThick(image, cx - 18, cy + 22, 28, black);
  drawCircleThick(image, cx + 18, cy + 22, 28, black);
  drawCircleThick(image, cx, cy - 32, 28, black);

  // Outer petals
  drawOvalThick(image, cx - 55, cy, 32, 42, black);
  drawOvalThick(image, cx + 55, cy, 32, 42, black);
  drawOvalThick(image, cx, cy + 55, 42, 32, black);

  // Stem
  drawLineThick(image, cx - 2, cy + 85, cx - 2, 350, black);
  drawLineThick(image, cx + 2, cy + 85, cx + 2, 350, black);

  // Thorns
  drawTriangleThick(image, cx, 240, cx - 18, 230, cx, 250, black);
  drawTriangleThick(image, cx, 290, cx + 18, 280, cx, 300, black);

  // Leaves
  drawOvalThick(image, cx - 45, 300, 28, 14, black);
  drawOvalThick(image, cx + 45, 260, 28, 14, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateTulip() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 130;
  final black = img.ColorRgb8(0, 0, 0);

  // Petals
  drawOvalThick(image, cx - 40, cy, 30, 55, black);
  drawOvalThick(image, cx, cy - 15, 25, 60, black);
  drawOvalThick(image, cx + 40, cy, 30, 55, black);

  // Stem
  drawLineThick(image, cx - 3, cy + 55, cx - 3, 360, black);
  drawLineThick(image, cx + 3, cy + 55, cx + 3, 360, black);

  // Leaves
  drawOvalThick(image, cx - 50, 280, 20, 60, black);
  drawOvalThick(image, cx + 50, 290, 20, 55, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateSunflower() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 130;
  final black = img.ColorRgb8(0, 0, 0);

  // Petals
  for (int i = 0; i < 12; i++) {
    final angle = i * math.pi / 6;
    final px = cx + (65 * math.cos(angle)).round();
    final py = cy + (65 * math.sin(angle)).round();
    drawOvalRotated(image, px, py, 15, 35, angle, black);
  }

  // Center
  drawCircleThick(image, cx, cy, 40, black);

  // Center pattern
  for (int i = 0; i < 8; i++) {
    final angle = i * math.pi / 4 + math.pi / 8;
    final px = cx + (20 * math.cos(angle)).round();
    final py = cy + (20 * math.sin(angle)).round();
    drawCircleThick(image, px, py, 8, black);
  }

  // Stem
  drawLineThick(image, cx - 4, cy + 75, cx - 4, 370, black);
  drawLineThick(image, cx + 4, cy + 75, cx + 4, 370, black);

  // Leaves
  drawOvalThick(image, cx - 55, 260, 35, 18, black);
  drawOvalThick(image, cx + 55, 300, 35, 18, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateCactus() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Main body
  drawRectThick(image, cx - 40, 100, cx + 40, 340, black);
  drawArcTopThick(image, cx, 100, 40, black);

  // Left arm
  drawRectThick(image, cx - 100, 150, cx - 40, 180, black);
  drawRectThick(image, cx - 100, 120, cx - 70, 180, black);
  drawArcTopThick(image, cx - 85, 120, 15, black);

  // Right arm
  drawRectThick(image, cx + 40, 200, cx + 100, 230, black);
  drawRectThick(image, cx + 70, 170, cx + 100, 230, black);
  drawArcTopThick(image, cx + 85, 170, 15, black);

  // Pot
  drawRectThick(image, cx - 60, 340, cx + 60, 380, black);
  drawLineThick(image, cx - 55, 350, cx + 55, 350, black);

  // Flower
  drawCircleThick(image, cx, 85, 18, black);
  for (int i = 0; i < 5; i++) {
    final angle = i * math.pi * 2 / 5 - math.pi / 2;
    final px = cx + (25 * math.cos(angle)).round();
    final py = 85 + (25 * math.sin(angle)).round();
    drawCircleThick(image, px, py, 12, black);
  }

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateMushroom() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Cap
  drawArcTopThick(image, cx, 180, 100, black);
  drawLineThick(image, cx - 100, 180, cx + 100, 180, black);

  // Cap spots
  drawCircleThick(image, cx - 40, 130, 20, black);
  drawCircleThick(image, cx + 50, 140, 15, black);
  drawCircleThick(image, cx, 100, 18, black);
  drawCircleThick(image, cx - 60, 165, 12, black);
  drawCircleThick(image, cx + 70, 160, 14, black);

  // Stem
  drawLineThick(image, cx - 35, 180, cx - 45, 350, black);
  drawLineThick(image, cx + 35, 180, cx + 45, 350, black);
  drawLineThick(image, cx - 45, 350, cx + 45, 350, black);

  // Grass
  drawLineThick(image, cx - 100, 350, cx - 80, 320, black);
  drawLineThick(image, cx - 70, 350, cx - 60, 325, black);
  drawLineThick(image, cx + 70, 350, cx + 60, 320, black);
  drawLineThick(image, cx + 100, 350, cx + 80, 325, black);

  return Uint8List.fromList(img.encodePng(image));
}

// ==================== VEHICLES ====================

Uint8List generateCar() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final black = img.ColorRgb8(0, 0, 0);
  final baseY = 220;

  // Body
  drawRectThick(image, 45, baseY - 45, 355, baseY + 25, black);

  // Cabin
  drawLineThick(image, 95, baseY - 45, 115, baseY - 95, black);
  drawLineThick(image, 115, baseY - 95, 285, baseY - 95, black);
  drawLineThick(image, 285, baseY - 95, 305, baseY - 45, black);

  // Windows
  drawRectThick(image, 125, baseY - 85, 190, baseY - 50, black);
  drawRectThick(image, 210, baseY - 85, 275, baseY - 50, black);

  // Wheels
  drawCircleThick(image, 105, baseY + 35, 38, black);
  drawCircleThick(image, 295, baseY + 35, 38, black);

  // Wheel centers
  drawCircleThick(image, 105, baseY + 35, 15, black);
  drawCircleThick(image, 295, baseY + 35, 15, black);

  // Headlights
  drawCircleThick(image, 345, baseY - 10, 14, black);
  drawCircleThick(image, 55, baseY - 10, 14, black);

  // Door handle
  drawLineThick(image, 220, baseY - 20, 260, baseY - 20, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generatePlane() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Body
  drawOvalThick(image, cx, cy, 145, 28, black);

  // Nose
  drawTriangleThick(image, cx + 145, cy, cx + 180, cy - 8, cx + 180, cy + 8, black);

  // Wings
  drawTriangleThick(image, cx - 25, cy - 28, cx + 25, cy - 28, cx, cy - 100, black);
  drawTriangleThick(image, cx - 25, cy + 28, cx + 25, cy + 28, cx, cy + 100, black);

  // Tail
  drawTriangleThick(image, cx - 145, cy - 28, cx - 125, cy - 28, cx - 135, cy - 72, black);

  // Windows
  for (int i = 0; i < 5; i++) {
    drawCircleThick(image, cx - 75 + i * 35, cy - 8, 10, black);
  }

  // Engine
  drawOvalThick(image, cx - 60, cy + 60, 20, 12, black);
  drawOvalThick(image, cx + 60, cy + 60, 20, 12, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateBoat() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Hull
  drawLineThick(image, 45, 245, 95, 300, black);
  drawLineThick(image, 95, 300, 305, 300, black);
  drawLineThick(image, 305, 300, 355, 245, black);
  drawLineThick(image, 45, 245, 355, 245, black);

  // Deck line
  drawLineThick(image, 95, 265, 305, 265, black);

  // Mast
  drawLineThick(image, cx - 3, 215, cx - 3, 70, black);
  drawLineThick(image, cx + 3, 215, cx + 3, 70, black);

  // Sail
  drawTriangleThick(image, cx + 8, 85, cx + 8, 200, cx + 105, 200, black);
  drawTriangleThick(image, cx - 8, 90, cx - 8, 195, cx - 80, 195, black);

  // Flag
  drawTriangleThick(image, cx - 3, 70, cx - 3, 95, cx - 38, 82, black);

  // Waves
  for (int i = 0; i < 4; i++) {
    final x = 55 + i * 85;
    drawArcThick(image, x, 325, 32, black);
  }

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateTrain() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final black = img.ColorRgb8(0, 0, 0);
  final baseY = 250;

  // Engine body
  drawRectThick(image, 30, baseY - 80, 180, baseY, black);

  // Cabin
  drawRectThick(image, 30, baseY - 140, 100, baseY - 80, black);

  // Smokestack
  drawRectThick(image, 130, baseY - 120, 160, baseY - 80, black);
  drawOvalThick(image, 145, baseY - 130, 20, 12, black);

  // Wheels
  drawCircleThick(image, 60, baseY + 20, 30, black);
  drawCircleThick(image, 150, baseY + 20, 30, black);
  drawCircleThick(image, 60, baseY + 20, 12, black);
  drawCircleThick(image, 150, baseY + 20, 12, black);

  // Car
  drawRectThick(image, 200, baseY - 60, 370, baseY, black);
  drawCircleThick(image, 240, baseY + 20, 25, black);
  drawCircleThick(image, 330, baseY + 20, 25, black);

  // Windows
  drawRectThick(image, 220, baseY - 45, 260, baseY - 15, black);
  drawRectThick(image, 280, baseY - 45, 320, baseY - 15, black);

  // Track
  drawLineThick(image, 10, baseY + 55, 390, baseY + 55, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateHelicopter() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Body
  drawOvalThick(image, cx, cy, 90, 45, black);

  // Cockpit
  drawOvalThick(image, cx + 60, cy, 40, 35, black);

  // Tail boom
  drawLineThick(image, cx - 90, cy - 10, cx - 160, cy - 40, black);
  drawLineThick(image, cx - 90, cy + 10, cx - 160, cy, black);

  // Tail rotor
  drawCircleThick(image, cx - 165, cy - 20, 25, black);
  drawLineThick(image, cx - 165, cy - 45, cx - 165, cy + 5, black);

  // Main rotor
  drawLineThick(image, cx - 120, cy - 60, cx + 120, cy - 60, black);
  drawOvalThick(image, cx, cy - 60, 8, 12, black);

  // Skids
  drawLineThick(image, cx - 60, cy + 55, cx + 80, cy + 55, black);
  drawLineThick(image, cx - 30, cy + 45, cx - 30, cy + 55, black);
  drawLineThick(image, cx + 50, cy + 45, cx + 50, cy + 55, black);

  // Window
  drawOvalThick(image, cx + 50, cy - 5, 25, 20, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateRocket() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Body
  drawRectThick(image, cx - 40, 100, cx + 40, 300, black);

  // Nose cone
  drawTriangleThick(image, cx - 40, 100, cx + 40, 100, cx, 30, black);

  // Fins
  drawTriangleThick(image, cx - 40, 260, cx - 40, 320, cx - 90, 320, black);
  drawTriangleThick(image, cx + 40, 260, cx + 40, 320, cx + 90, 320, black);

  // Window
  drawCircleThick(image, cx, 160, 25, black);

  // Exhaust
  drawTriangleThick(image, cx - 30, 300, cx + 30, 300, cx, 370, black);
  drawTriangleThick(image, cx - 15, 310, cx + 15, 310, cx, 350, black);

  // Details
  drawLineThick(image, cx - 40, 200, cx + 40, 200, black);
  drawLineThick(image, cx - 40, 250, cx + 40, 250, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateBicycle() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final black = img.ColorRgb8(0, 0, 0);

  // Wheels
  drawCircleThick(image, 100, 260, 55, black);
  drawCircleThick(image, 300, 260, 55, black);
  drawCircleThick(image, 100, 260, 8, black);
  drawCircleThick(image, 300, 260, 8, black);

  // Spokes
  for (int i = 0; i < 8; i++) {
    final angle = i * math.pi / 4;
    drawLineThick(image, 100, 260,
      100 + (50 * math.cos(angle)).round(),
      260 + (50 * math.sin(angle)).round(), black);
    drawLineThick(image, 300, 260,
      300 + (50 * math.cos(angle)).round(),
      260 + (50 * math.sin(angle)).round(), black);
  }

  // Frame
  drawLineThick(image, 100, 260, 200, 180, black);
  drawLineThick(image, 200, 180, 300, 260, black);
  drawLineThick(image, 200, 180, 200, 260, black);
  drawLineThick(image, 200, 260, 300, 260, black);

  // Handlebars
  drawLineThick(image, 300, 260, 320, 160, black);
  drawLineThick(image, 300, 160, 340, 160, black);

  // Seat
  drawLineThick(image, 200, 180, 180, 130, black);
  drawLineThick(image, 160, 130, 200, 130, black);

  // Pedals
  drawCircleThick(image, 200, 260, 15, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateBus() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final black = img.ColorRgb8(0, 0, 0);
  final baseY = 230;

  // Body
  drawRectThick(image, 30, baseY - 100, 370, baseY + 20, black);

  // Roof curve
  drawArcTopThick(image, 200, baseY - 100, 170, black);

  // Windows
  for (int i = 0; i < 4; i++) {
    drawRectThick(image, 60 + i * 80, baseY - 80, 120 + i * 80, baseY - 30, black);
  }

  // Door
  drawRectThick(image, 310, baseY - 80, 355, baseY + 15, black);
  drawCircleThick(image, 345, baseY - 30, 6, black);

  // Wheels
  drawCircleThick(image, 90, baseY + 35, 35, black);
  drawCircleThick(image, 310, baseY + 35, 35, black);
  drawCircleThick(image, 90, baseY + 35, 14, black);
  drawCircleThick(image, 310, baseY + 35, 14, black);

  // Headlights
  drawCircleThick(image, 355, baseY - 10, 12, black);
  drawCircleThick(image, 45, baseY - 10, 12, black);

  return Uint8List.fromList(img.encodePng(image));
}

// ==================== CHARACTERS ====================

Uint8List generatePrincess() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 140;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawCircleThick(image, cx, cy, 50, black);

  // Crown
  drawLineThick(image, cx - 42, cy - 48, cx - 52, cy - 90, black);
  drawLineThick(image, cx - 52, cy - 90, cx - 22, cy - 70, black);
  drawLineThick(image, cx - 22, cy - 70, cx, cy - 100, black);
  drawLineThick(image, cx, cy - 100, cx + 22, cy - 70, black);
  drawLineThick(image, cx + 22, cy - 70, cx + 52, cy - 90, black);
  drawLineThick(image, cx + 52, cy - 90, cx + 42, cy - 48, black);
  drawCircleThick(image, cx, cy - 95, 8, black);

  // Eyes
  drawOvalThick(image, cx - 18, cy - 8, 10, 14, black);
  drawOvalThick(image, cx + 18, cy - 8, 10, 14, black);

  // Smile
  drawArcThick(image, cx, cy + 22, 22, black);

  // Hair
  drawLineThick(image, cx - 50, cy, cx - 62, cy + 85, black);
  drawLineThick(image, cx + 50, cy, cx + 62, cy + 85, black);
  drawLineThick(image, cx - 55, cy + 30, cx - 68, cy + 70, black);
  drawLineThick(image, cx + 55, cy + 30, cx + 68, cy + 70, black);

  // Dress
  drawTriangleThick(image, cx - 85, 385, cx + 85, 385, cx, cy + 50, black);

  // Dress details
  drawLineThick(image, cx - 40, cy + 100, cx + 40, cy + 100, black);
  drawArcThick(image, cx, cy + 150, 50, black);

  // Arms
  drawLineThick(image, cx - 38, cy + 80, cx - 85, cy + 130, black);
  drawLineThick(image, cx + 38, cy + 80, cx + 85, cy + 130, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateSuperhero() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 110;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawCircleThick(image, cx, cy, 48, black);

  // Mask
  drawLineThick(image, cx - 48, cy - 8, cx - 18, cy - 8, black);
  drawLineThick(image, cx + 48, cy - 8, cx + 18, cy - 8, black);

  // Eyes
  drawOvalThick(image, cx - 18, cy - 2, 12, 16, black);
  drawOvalThick(image, cx + 18, cy - 2, 12, 16, black);

  // Body
  drawOvalThick(image, cx, cy + 115, 52, 72, black);

  // Cape
  drawTriangleThick(image, cx - 52, cy + 58, cx + 52, cy + 58, cx - 85, cy + 205, black);
  drawTriangleThick(image, cx - 52, cy + 58, cx + 52, cy + 58, cx + 85, cy + 205, black);

  // Arms (muscular)
  drawOvalThick(image, cx - 72, cy + 100, 28, 52, black);
  drawOvalThick(image, cx + 72, cy + 100, 28, 52, black);

  // Fists
  drawCircleThick(image, cx - 72, cy + 162, 18, black);
  drawCircleThick(image, cx + 72, cy + 162, 18, black);

  // Legs
  drawRectThick(image, cx - 38, cy + 185, cx - 8, cy + 290, black);
  drawRectThick(image, cx + 8, cy + 185, cx + 38, cy + 290, black);

  // Logo on chest
  drawTriangleThick(image, cx - 22, cy + 72, cx + 22, cy + 72, cx, cy + 115, black);

  // Belt
  drawLineThick(image, cx - 50, cy + 175, cx + 50, cy + 175, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateRobot() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 100;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawRectThick(image, cx - 55, cy - 55, cx + 55, cy + 55, black);

  // Antenna
  drawLineThick(image, cx, cy - 55, cx, cy - 90, black);
  drawCircleThick(image, cx, cy - 95, 12, black);

  // Eyes
  drawCircleThick(image, cx - 25, cy - 10, 18, black);
  drawCircleThick(image, cx + 25, cy - 10, 18, black);

  // Mouth
  drawRectThick(image, cx - 30, cy + 25, cx + 30, cy + 42, black);
  for (int i = 0; i < 5; i++) {
    drawLineThick(image, cx - 25 + i * 12, cy + 25, cx - 25 + i * 12, cy + 42, black);
  }

  // Body
  drawRectThick(image, cx - 70, cy + 70, cx + 70, cy + 200, black);

  // Chest panel
  drawRectThick(image, cx - 45, cy + 90, cx + 45, cy + 160, black);
  drawCircleThick(image, cx - 20, cy + 115, 12, black);
  drawCircleThick(image, cx + 20, cy + 115, 12, black);
  drawRectThick(image, cx - 30, cy + 135, cx + 30, cy + 150, black);

  // Arms
  drawRectThick(image, cx - 100, cy + 80, cx - 70, cy + 170, black);
  drawRectThick(image, cx + 70, cy + 80, cx + 100, cy + 170, black);
  drawCircleThick(image, cx - 85, cy + 180, 18, black);
  drawCircleThick(image, cx + 85, cy + 180, 18, black);

  // Legs
  drawRectThick(image, cx - 50, cy + 200, cx - 15, cy + 300, black);
  drawRectThick(image, cx + 15, cy + 200, cx + 50, cy + 300, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generatePirate() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 120;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawCircleThick(image, cx, cy, 55, black);

  // Hat
  drawLineThick(image, cx - 70, cy - 35, cx + 70, cy - 35, black);
  drawArcTopThick(image, cx, cy - 35, 55, black);

  // Skull on hat
  drawCircleThick(image, cx, cy - 65, 12, black);

  // Eye patch
  drawOvalThick(image, cx - 22, cy - 8, 15, 18, black);
  drawLineThick(image, cx - 35, cy - 15, cx - 55, cy - 40, black);

  // Good eye
  drawCircleThick(image, cx + 22, cy - 8, 10, black);

  // Beard
  drawLineThick(image, cx - 40, cy + 30, cx - 50, cy + 80, black);
  drawLineThick(image, cx - 20, cy + 45, cx - 25, cy + 90, black);
  drawLineThick(image, cx, cy + 50, cx, cy + 95, black);
  drawLineThick(image, cx + 20, cy + 45, cx + 25, cy + 90, black);
  drawLineThick(image, cx + 40, cy + 30, cx + 50, cy + 80, black);

  // Body
  drawRectThick(image, cx - 50, cy + 70, cx + 50, cy + 180, black);

  // Vest lines
  drawLineThick(image, cx - 30, cy + 70, cx - 35, cy + 180, black);
  drawLineThick(image, cx + 30, cy + 70, cx + 35, cy + 180, black);

  // Arms
  drawLineThick(image, cx - 50, cy + 90, cx - 100, cy + 150, black);
  drawLineThick(image, cx + 50, cy + 90, cx + 100, cy + 150, black);

  // Hook
  drawArcThick(image, cx + 110, cy + 165, 18, black);

  // Legs
  drawRectThick(image, cx - 40, cy + 180, cx - 10, cy + 280, black);
  drawRectThick(image, cx + 10, cy + 180, cx + 40, cy + 280, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateFairy() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 130;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawCircleThick(image, cx, cy, 40, black);

  // Hair
  for (int i = 0; i < 5; i++) {
    final angle = -math.pi / 2 + (i - 2) * math.pi / 8;
    drawLineThick(image,
      cx + (40 * math.cos(angle)).round(),
      cy + (40 * math.sin(angle)).round(),
      cx + (70 * math.cos(angle)).round(),
      cy + (70 * math.sin(angle)).round(), black);
  }

  // Eyes
  drawCircleThick(image, cx - 15, cy - 5, 8, black);
  drawCircleThick(image, cx + 15, cy - 5, 8, black);

  // Smile
  drawArcThick(image, cx, cy + 18, 15, black);

  // Wings
  drawOvalThick(image, cx - 70, cy + 60, 45, 65, black);
  drawOvalThick(image, cx + 70, cy + 60, 45, 65, black);
  drawOvalThick(image, cx - 55, cy + 100, 30, 40, black);
  drawOvalThick(image, cx + 55, cy + 100, 30, 40, black);

  // Body/Dress
  drawTriangleThick(image, cx - 40, cy + 240, cx + 40, cy + 240, cx, cy + 50, black);

  // Arms
  drawLineThick(image, cx - 25, cy + 90, cx - 60, cy + 60, black);
  drawLineThick(image, cx + 25, cy + 90, cx + 60, cy + 60, black);

  // Wand
  drawLineThick(image, cx + 60, cy + 60, cx + 100, cy + 20, black);
  drawCircleThick(image, cx + 105, cy + 15, 12, black);
  for (int i = 0; i < 4; i++) {
    final angle = i * math.pi / 2;
    drawLineThick(image, cx + 105, cy + 15,
      cx + 105 + (20 * math.cos(angle)).round(),
      cy + 15 + (20 * math.sin(angle)).round(), black);
  }

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateKnight() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 100;
  final black = img.ColorRgb8(0, 0, 0);

  // Helmet
  drawOvalThick(image, cx, cy, 50, 55, black);

  // Visor
  drawLineThick(image, cx - 45, cy, cx + 45, cy, black);
  drawLineThick(image, cx - 40, cy + 10, cx + 40, cy + 10, black);
  drawLineThick(image, cx - 35, cy + 20, cx + 35, cy + 20, black);

  // Plume
  for (int i = 0; i < 3; i++) {
    drawLineThick(image, cx, cy - 55, cx - 30 + i * 15, cy - 100, black);
  }

  // Body (armor)
  drawRectThick(image, cx - 55, cy + 60, cx + 55, cy + 180, black);

  // Armor details
  drawLineThick(image, cx, cy + 60, cx, cy + 180, black);
  drawLineThick(image, cx - 55, cy + 100, cx + 55, cy + 100, black);
  drawLineThick(image, cx - 55, cy + 140, cx + 55, cy + 140, black);

  // Arms with armor
  drawRectThick(image, cx - 90, cy + 70, cx - 55, cy + 140, black);
  drawRectThick(image, cx + 55, cy + 70, cx + 90, cy + 140, black);

  // Sword
  drawLineThick(image, cx + 95, cy + 70, cx + 95, cy - 30, black);
  drawLineThick(image, cx + 85, cy + 55, cx + 105, cy + 55, black);

  // Shield
  drawOvalThick(image, cx - 100, cy + 100, 35, 50, black);
  drawLineThick(image, cx - 100, cy + 60, cx - 100, cy + 140, black);
  drawLineThick(image, cx - 130, cy + 100, cx - 70, cy + 100, black);

  // Legs
  drawRectThick(image, cx - 45, cy + 180, cx - 10, cy + 290, black);
  drawRectThick(image, cx + 10, cy + 180, cx + 45, cy + 290, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateMermaid() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 110;
  final black = img.ColorRgb8(0, 0, 0);

  // Head
  drawCircleThick(image, cx, cy, 45, black);

  // Hair
  drawLineThick(image, cx - 45, cy, cx - 70, cy + 100, black);
  drawLineThick(image, cx + 45, cy, cx + 70, cy + 100, black);
  drawLineThick(image, cx - 40, cy + 20, cx - 60, cy + 80, black);
  drawLineThick(image, cx + 40, cy + 20, cx + 60, cy + 80, black);

  // Crown/tiara
  drawArcTopThick(image, cx, cy - 45, 30, black);

  // Eyes
  drawOvalThick(image, cx - 15, cy - 5, 8, 12, black);
  drawOvalThick(image, cx + 15, cy - 5, 8, 12, black);

  // Smile
  drawArcThick(image, cx, cy + 20, 18, black);

  // Body
  drawOvalThick(image, cx, cy + 90, 40, 50, black);

  // Arms
  drawLineThick(image, cx - 35, cy + 70, cx - 80, cy + 100, black);
  drawLineThick(image, cx + 35, cy + 70, cx + 80, cy + 100, black);

  // Tail
  drawOvalThick(image, cx, cy + 180, 35, 60, black);
  drawOvalThick(image, cx, cy + 260, 30, 40, black);

  // Tail fin
  drawTriangleThick(image, cx - 55, cy + 310, cx + 55, cy + 310, cx, cy + 280, black);
  drawLineThick(image, cx, cy + 280, cx, cy + 310, black);

  // Scale details
  for (int i = 0; i < 3; i++) {
    drawArcThick(image, cx, cy + 150 + i * 30, 25, black);
  }

  return Uint8List.fromList(img.encodePng(image));
}

// ==================== NATURE ====================

Uint8List generateSun() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Main circle
  drawCircleThick(image, cx, cy, 70, black);

  // Rays
  for (int i = 0; i < 12; i++) {
    final angle = i * math.pi / 6;
    final sx = cx + (80 * math.cos(angle)).round();
    final sy = cy + (80 * math.sin(angle)).round();
    final ex = cx + (130 * math.cos(angle)).round();
    final ey = cy + (130 * math.sin(angle)).round();
    drawLineThick(image, sx, sy, ex, ey, black);
  }

  // Happy face
  drawCircleThick(image, cx - 25, cy - 18, 10, black);
  drawCircleThick(image, cx + 25, cy - 18, 10, black);
  drawArcThick(image, cx, cy + 22, 32, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateRainbow() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 300;
  final black = img.ColorRgb8(0, 0, 0);

  // Rainbow arcs
  for (int i = 0; i < 7; i++) {
    drawArcTopThick(image, cx, cy, 180 - i * 22, black);
  }

  // Clouds
  drawCircleThick(image, 55, cy - 8, 32, black);
  drawCircleThick(image, 88, cy - 20, 28, black);
  drawCircleThick(image, 115, cy - 3, 22, black);

  drawCircleThick(image, 345, cy - 8, 32, black);
  drawCircleThick(image, 312, cy - 20, 28, black);
  drawCircleThick(image, 285, cy - 3, 22, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateCloud() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Cloud bumps
  drawCircleThick(image, cx - 80, cy + 10, 45, black);
  drawCircleThick(image, cx - 30, cy - 30, 55, black);
  drawCircleThick(image, cx + 40, cy - 20, 50, black);
  drawCircleThick(image, cx + 90, cy + 15, 40, black);
  drawCircleThick(image, cx, cy + 30, 50, black);
  drawCircleThick(image, cx + 50, cy + 35, 42, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateStar() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // 5-pointed star
  final outerRadius = 120;
  final innerRadius = 50;

  for (int i = 0; i < 5; i++) {
    final angle1 = (i * 2 * math.pi / 5) - math.pi / 2;
    final angle2 = ((i + 0.5) * 2 * math.pi / 5) - math.pi / 2;
    final angle3 = ((i + 1) * 2 * math.pi / 5) - math.pi / 2;

    final x1 = cx + (outerRadius * math.cos(angle1)).round();
    final y1 = cy + (outerRadius * math.sin(angle1)).round();
    final x2 = cx + (innerRadius * math.cos(angle2)).round();
    final y2 = cy + (innerRadius * math.sin(angle2)).round();
    final x3 = cx + (outerRadius * math.cos(angle3)).round();
    final y3 = cy + (outerRadius * math.sin(angle3)).round();

    drawLineThick(image, x1, y1, x2, y2, black);
    drawLineThick(image, x2, y2, x3, y3, black);
  }

  // Happy face
  drawCircleThick(image, cx - 20, cy - 15, 8, black);
  drawCircleThick(image, cx + 20, cy - 15, 8, black);
  drawArcThick(image, cx, cy + 15, 20, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateMoon() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Crescent moon
  drawCircleThick(image, cx, cy, 100, black);

  // Inner circle to create crescent (white fill effect with outline)
  drawCircleThick(image, cx + 50, cy - 30, 80, black);

  // Stars around
  drawStarSmall(image, 80, 100, black);
  drawStarSmall(image, 320, 80, black);
  drawStarSmall(image, 100, 300, black);
  drawStarSmall(image, 340, 280, black);
  drawStarSmall(image, 60, 200, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateMountain() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final black = img.ColorRgb8(0, 0, 0);

  // Back mountain
  drawTriangleThick(image, 50, 320, 250, 320, 150, 120, black);

  // Front mountain
  drawTriangleThick(image, 150, 320, 380, 320, 280, 80, black);

  // Snow cap
  drawTriangleThick(image, 230, 140, 330, 140, 280, 80, black);
  drawLineThick(image, 245, 140, 260, 180, black);
  drawLineThick(image, 300, 140, 315, 175, black);

  // Sun
  drawCircleThick(image, 80, 80, 35, black);
  for (int i = 0; i < 8; i++) {
    final angle = i * math.pi / 4;
    drawLineThick(image,
      80 + (45 * math.cos(angle)).round(),
      80 + (45 * math.sin(angle)).round(),
      80 + (65 * math.cos(angle)).round(),
      80 + (65 * math.sin(angle)).round(), black);
  }

  // Ground line
  drawLineThick(image, 20, 320, 380, 320, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateWave() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final black = img.ColorRgb8(0, 0, 0);

  // Multiple wave layers
  for (int layer = 0; layer < 4; layer++) {
    final y = 150 + layer * 50;
    for (int i = 0; i < 4; i++) {
      final x = 50 + i * 100;
      drawArcThick(image, x, y, 40, black);
      drawArcTopThick(image, x + 50, y, 40, black);
    }
  }

  // Fish
  drawOvalThick(image, 300, 250, 30, 18, black);
  drawTriangleThick(image, 270, 250, 250, 235, 250, 265, black);
  drawCircleThick(image, 315, 245, 5, black);

  // Bubbles
  drawCircleThick(image, 340, 200, 10, black);
  drawCircleThick(image, 355, 220, 7, black);
  drawCircleThick(image, 330, 230, 5, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateSnowflake() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Main 6 branches
  for (int i = 0; i < 6; i++) {
    final angle = i * math.pi / 3;
    final ex = cx + (120 * math.cos(angle)).round();
    final ey = cy + (120 * math.sin(angle)).round();
    drawLineThick(image, cx, cy, ex, ey, black);

    // Branch details
    for (int j = 1; j <= 2; j++) {
      final bx = cx + (40 * j * math.cos(angle)).round();
      final by = cy + (40 * j * math.sin(angle)).round();

      final leftAngle = angle + math.pi / 4;
      final rightAngle = angle - math.pi / 4;

      drawLineThick(image, bx, by,
        bx + (25 * math.cos(leftAngle)).round(),
        by + (25 * math.sin(leftAngle)).round(), black);
      drawLineThick(image, bx, by,
        bx + (25 * math.cos(rightAngle)).round(),
        by + (25 * math.sin(rightAngle)).round(), black);
    }
  }

  // Center
  drawCircleThick(image, cx, cy, 15, black);

  return Uint8List.fromList(img.encodePng(image));
}

// ==================== FOOD ====================

Uint8List generateApple() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 220;
  final black = img.ColorRgb8(0, 0, 0);

  // Apple body (two overlapping circles)
  drawCircleThick(image, cx - 35, cy, 80, black);
  drawCircleThick(image, cx + 35, cy, 80, black);

  // Indent at top
  drawArcThick(image, cx, cy - 75, 25, black);

  // Stem
  drawRectThick(image, cx - 6, cy - 105, cx + 6, cy - 70, black);

  // Leaf
  drawOvalThick(image, cx + 40, cy - 100, 32, 16, black);
  drawLineThick(image, cx + 20, cy - 100, cx + 60, cy - 100, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateIcecream() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Cone
  drawTriangleThick(image, cx - 65, 175, cx + 65, 175, cx, 385, black);

  // Cone pattern
  for (int i = 0; i < 5; i++) {
    drawLineThick(image, cx - 55 + i * 27, 195, cx - 28 + i * 14, 310, black);
  }
  for (int i = 0; i < 4; i++) {
    drawLineThick(image, cx + 55 - i * 27, 195, cx + 28 - i * 14, 310, black);
  }

  // Scoops
  drawCircleThick(image, cx, 135, 62, black);
  drawCircleThick(image, cx - 42, 85, 48, black);
  drawCircleThick(image, cx + 42, 85, 48, black);
  drawCircleThick(image, cx, 45, 42, black);

  // Cherry on top
  drawCircleThick(image, cx, 15, 18, black);
  drawLineThick(image, cx, 0, cx + 12, -18, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateCupcake() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Cup
  drawLineThick(image, cx - 70, 220, cx - 55, 340, black);
  drawLineThick(image, cx + 70, 220, cx + 55, 340, black);
  drawLineThick(image, cx - 55, 340, cx + 55, 340, black);

  // Cup lines
  for (int i = 0; i < 5; i++) {
    drawLineThick(image, cx - 60 + i * 30, 220, cx - 48 + i * 24, 340, black);
  }

  // Frosting swirls
  drawCircleThick(image, cx - 50, 180, 40, black);
  drawCircleThick(image, cx + 50, 180, 40, black);
  drawCircleThick(image, cx, 150, 45, black);
  drawCircleThick(image, cx - 30, 120, 35, black);
  drawCircleThick(image, cx + 30, 120, 35, black);
  drawCircleThick(image, cx, 90, 30, black);

  // Cherry
  drawCircleThick(image, cx, 60, 18, black);
  drawLineThick(image, cx, 45, cx + 10, 25, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generatePizza() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 220;
  final black = img.ColorRgb8(0, 0, 0);

  // Pizza slice (triangle with curved bottom)
  drawLineThick(image, cx, cy - 150, cx - 120, cy + 80, black);
  drawLineThick(image, cx, cy - 150, cx + 120, cy + 80, black);
  drawArcThick(image, cx, cy + 80, 120, black);

  // Crust
  drawArcThick(image, cx, cy + 60, 105, black);

  // Pepperoni
  drawCircleThick(image, cx - 40, cy - 40, 22, black);
  drawCircleThick(image, cx + 45, cy - 20, 20, black);
  drawCircleThick(image, cx, cy + 30, 18, black);
  drawCircleThick(image, cx - 50, cy + 40, 16, black);
  drawCircleThick(image, cx + 55, cy + 50, 17, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateWatermelon() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 250;
  final black = img.ColorRgb8(0, 0, 0);

  // Slice shape
  drawArcTopThick(image, cx, cy, 140, black);
  drawLineThick(image, cx - 140, cy, cx + 140, cy, black);

  // Rind
  drawArcTopThick(image, cx, cy, 120, black);

  // Seeds
  drawOvalThick(image, cx - 60, cy - 50, 8, 15, black);
  drawOvalThick(image, cx + 60, cy - 45, 8, 15, black);
  drawOvalThick(image, cx - 20, cy - 80, 8, 15, black);
  drawOvalThick(image, cx + 30, cy - 75, 8, 15, black);
  drawOvalThick(image, cx, cy - 40, 8, 15, black);
  drawOvalThick(image, cx - 80, cy - 25, 8, 12, black);
  drawOvalThick(image, cx + 90, cy - 20, 8, 12, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateCookie() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 200;
  final black = img.ColorRgb8(0, 0, 0);

  // Cookie shape (slightly irregular circle)
  drawCircleThick(image, cx, cy, 110, black);

  // Chocolate chips
  drawCircleThick(image, cx - 50, cy - 40, 18, black);
  drawCircleThick(image, cx + 55, cy - 35, 16, black);
  drawCircleThick(image, cx - 20, cy + 50, 17, black);
  drawCircleThick(image, cx + 40, cy + 45, 15, black);
  drawCircleThick(image, cx + 10, cy - 10, 14, black);
  drawCircleThick(image, cx - 60, cy + 25, 13, black);
  drawCircleThick(image, cx + 70, cy + 10, 12, black);
  drawCircleThick(image, cx - 10, cy - 65, 14, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateLollipop() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final cx = 200, cy = 140;
  final black = img.ColorRgb8(0, 0, 0);

  // Candy
  drawCircleThick(image, cx, cy, 90, black);

  // Spiral pattern
  for (int i = 1; i <= 3; i++) {
    drawCircleThick(image, cx, cy, 90 - i * 25, black);
  }

  // Stick
  drawRectThick(image, cx - 8, cy + 90, cx + 8, 380, black);

  // Bow
  drawOvalThick(image, cx - 35, cy + 110, 25, 15, black);
  drawOvalThick(image, cx + 35, cy + 110, 25, 15, black);
  drawCircleThick(image, cx, cy + 110, 10, black);

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List generateBanana() {
  final image = img.Image(width: 400, height: 400);
  fillWhite(image);

  final black = img.ColorRgb8(0, 0, 0);

  // Banana curve (using multiple arcs)
  // Outer curve
  drawArcLarge(image, 200, 350, 180, 50, 130, black);

  // Inner curve
  drawArcLarge(image, 200, 320, 150, 60, 120, black);

  // Ends
  drawLineThick(image, 85, 180, 70, 150, black);
  drawLineThick(image, 315, 180, 340, 160, black);

  // Top stem
  drawRectThick(image, 65, 140, 80, 155, black);

  // Spots
  drawCircleThick(image, 150, 220, 8, black);
  drawCircleThick(image, 200, 200, 6, black);
  drawCircleThick(image, 250, 210, 7, black);

  return Uint8List.fromList(img.encodePng(image));
}

// ==================== HELPER FUNCTIONS ====================

void fillWhite(img.Image image) {
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      image.setPixel(x, y, img.ColorRgb8(255, 255, 255));
    }
  }
}

void drawCircleThick(img.Image image, int cx, int cy, int radius, img.Color color) {
  for (int t = 0; t < lineThickness; t++) {
    final r = radius - t;
    if (r <= 0) continue;
    for (int angle = 0; angle < 360; angle++) {
      final rad = angle * math.pi / 180;
      final x = cx + (r * math.cos(rad)).round();
      final y = cy + (r * math.sin(rad)).round();
      setPixelSafe(image, x, y, color);
    }
  }
}

void drawOvalThick(img.Image image, int cx, int cy, int rx, int ry, img.Color color) {
  for (int t = 0; t < lineThickness; t++) {
    final rxT = rx - t;
    final ryT = ry - t;
    if (rxT <= 0 || ryT <= 0) continue;
    for (int angle = 0; angle < 360; angle++) {
      final rad = angle * math.pi / 180;
      final x = cx + (rxT * math.cos(rad)).round();
      final y = cy + (ryT * math.sin(rad)).round();
      setPixelSafe(image, x, y, color);
    }
  }
}

void drawOvalRotated(img.Image image, int cx, int cy, int rx, int ry, double rotation, img.Color color) {
  for (int t = 0; t < lineThickness; t++) {
    final rxT = rx - t ~/ 2;
    final ryT = ry - t ~/ 2;
    if (rxT <= 0 || ryT <= 0) continue;
    for (int angle = 0; angle < 360; angle++) {
      final rad = angle * math.pi / 180;
      final px = rxT * math.cos(rad);
      final py = ryT * math.sin(rad);
      final x = cx + (px * math.cos(rotation) - py * math.sin(rotation)).round();
      final y = cy + (px * math.sin(rotation) + py * math.cos(rotation)).round();
      setPixelSafe(image, x, y, color);
    }
  }
}

void drawLineThick(img.Image image, int x1, int y1, int x2, int y2, img.Color color) {
  for (int t = -lineThickness ~/ 2; t <= lineThickness ~/ 2; t++) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) continue;
    final nx = (-dy / len * t).round();
    final ny = (dx / len * t).round();
    drawLine(image, x1 + nx, y1 + ny, x2 + nx, y2 + ny, color);
  }
}

void drawLine(img.Image image, int x1, int y1, int x2, int y2, img.Color color) {
  final dx = (x2 - x1).abs();
  final dy = (y2 - y1).abs();
  final sx = x1 < x2 ? 1 : -1;
  final sy = y1 < y2 ? 1 : -1;
  var err = dx - dy;
  var x = x1, y = y1;

  while (true) {
    setPixelSafe(image, x, y, color);
    if (x == x2 && y == y2) break;
    final e2 = 2 * err;
    if (e2 > -dy) { err -= dy; x += sx; }
    if (e2 < dx) { err += dx; y += sy; }
  }
}

void drawRectThick(img.Image image, int x1, int y1, int x2, int y2, img.Color color) {
  drawLineThick(image, x1, y1, x2, y1, color);
  drawLineThick(image, x1, y2, x2, y2, color);
  drawLineThick(image, x1, y1, x1, y2, color);
  drawLineThick(image, x2, y1, x2, y2, color);
}

void drawTriangleThick(img.Image image, int x1, int y1, int x2, int y2, int x3, int y3, img.Color color) {
  drawLineThick(image, x1, y1, x2, y2, color);
  drawLineThick(image, x2, y2, x3, y3, color);
  drawLineThick(image, x3, y3, x1, y1, color);
}

void drawArcThick(img.Image image, int cx, int cy, int radius, img.Color color) {
  for (int t = 0; t < lineThickness; t++) {
    final r = radius - t;
    if (r <= 0) continue;
    for (int angle = 0; angle <= 180; angle++) {
      final rad = angle * math.pi / 180;
      final x = cx + (r * math.cos(rad)).round();
      final y = cy + (r * math.sin(rad)).round();
      setPixelSafe(image, x, y, color);
    }
  }
}

void drawArcTopThick(img.Image image, int cx, int cy, int radius, img.Color color) {
  for (int t = 0; t < lineThickness; t++) {
    final r = radius - t;
    if (r <= 0) continue;
    for (int angle = 180; angle <= 360; angle++) {
      final rad = angle * math.pi / 180;
      final x = cx + (r * math.cos(rad)).round();
      final y = cy + (r * math.sin(rad)).round();
      setPixelSafe(image, x, y, color);
    }
  }
}

void drawArcLarge(img.Image image, int cx, int cy, int radius, int startAngle, int endAngle, img.Color color) {
  for (int t = 0; t < lineThickness; t++) {
    final r = radius - t;
    if (r <= 0) continue;
    for (int angle = startAngle; angle <= endAngle; angle++) {
      final rad = angle * math.pi / 180;
      final x = cx + (r * math.cos(rad)).round();
      final y = cy + (r * math.sin(rad)).round();
      setPixelSafe(image, x, y, color);
    }
  }
}

void drawStarSmall(img.Image image, int cx, int cy, img.Color color) {
  // Simple 4-pointed star
  drawLineThick(image, cx, cy - 12, cx, cy + 12, color);
  drawLineThick(image, cx - 12, cy, cx + 12, cy, color);
  drawLineThick(image, cx - 8, cy - 8, cx + 8, cy + 8, color);
  drawLineThick(image, cx + 8, cy - 8, cx - 8, cy + 8, color);
}

void setPixelSafe(img.Image image, int x, int y, img.Color color) {
  if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
    image.setPixel(x, y, color);
  }
}
