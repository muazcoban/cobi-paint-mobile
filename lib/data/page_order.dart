import '../models/coloring_image.dart';
import '../models/saved_artwork.dart';
import '../models/user_settings.dart';

/// Pages are never locked; they are only ordered so a 3-year-old meets the
/// pages that suit them first. Nothing here is shown as a number, bar or
/// badge to the child.

/// Artworks of a level a child must have started before the next level's
/// pages move to the front.
const pagesPerLevel = 4;

/// The highest level Minik mode moves to on its own: fine detail needs the
/// zoom that only Büyük mode has.
const littleModeMaxLevel = 2;

/// The level whose pages come first.
///
/// A parent can pin a level in the Parents area ([UserSettings.level] 1-3);
/// 0 means automatic: start at 1 and move up once [pagesPerLevel] different
/// pages of the current level have been coloured, counted from the saved
/// artworks. Copies of one page and the Draw page count once: colouring the
/// same page four times is practice, not a new level.
int currentLevel(UserSettings settings, Iterable<SavedArtwork> artworks, Map<String, ColoringImage> pagesById) {
  if (settings.level >= 1 && settings.level <= 3) return settings.level;
  final max = settings.ageMode == AgeMode.little ? littleModeMaxLevel : 3;
  final started = <int, Set<String>>{};
  for (final artwork in artworks) {
    final page = pagesById[artwork.originalImageId];
    if (page != null) (started[page.level] ??= <String>{}).add(page.id);
  }
  var level = 1;
  while (level < max && (started[level]?.length ?? 0) >= pagesPerLevel) {
    level++;
  }
  return level;
}

/// Pages of [level] first, then the easier ones (nearest level first), then
/// the harder ones (nearest first). Stable within each group, so the catalog
/// order stays.
List<ColoringImage> orderPages(List<ColoringImage> pages, int level) {
  int rank(ColoringImage page) {
    if (page.level == level) return 0;
    return page.level < level ? level - page.level : 100 + page.level - level;
  }

  final indexed = List<MapEntry<int, ColoringImage>>.generate(pages.length, (i) => MapEntry(i, pages[i]));
  indexed.sort((a, b) {
    final r = rank(a.value).compareTo(rank(b.value));
    return r != 0 ? r : a.key.compareTo(b.key);
  });
  return [for (final e in indexed) e.value];
}
