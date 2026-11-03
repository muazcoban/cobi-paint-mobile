import '../models/coloring_image.dart';

/// The blank page behind the Draw card on the home screen. Every tap on the
/// card starts a new picture; finished ones live in My Artworks.
const freeDrawPage = ColoringImage(
  id: 'free_blank',
  name: 'Çizim',
  nameEn: 'Drawing',
  category: 'free',
  imagePath: 'assets/pages/free/blank.png',
  level: 1,
  freeDraw: true,
);
