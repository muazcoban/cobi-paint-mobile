// Measures fill regions of every coloring page the way coloring_provider.dart does today
// (gray threshold + Sobel edge mask, Otsu auto threshold, 8-connected fill).
// Input: a folder of .gray files made by png_to_gray.py (uint32 width, uint32 height, 8-bit gray pixels).
// Usage (run outside the Flutter project so its package config is not picked up):
//   python3 png_to_gray.py <assets/images/categories> <out_dir>
//   dart resim_olcumu.dart <out_dir> > resim-olcumleri.csv

import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

// Mirrors coloring_provider.dart edge logic, then measures region structure.
void main(List<String> args) {
  final files = Directory(args[0]).listSync().whereType<File>().where((f) => f.path.endsWith('.gray')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  print('name,w,h,regions8,regions4,regions8_closed2,bgPct8,bgPct_closed2,blackComps,haloPct');
  for (final f in files) {
    final b = f.readAsBytesSync();
    final w = ByteData.sublistView(b, 0, 4).getUint32(0, Endian.little);
    final h = ByteData.sublistView(b, 4, 8).getUint32(0, Endian.little);
    final g = Uint8List.sublistView(b, 8);
    final n = w * h;
    // Sobel gradient
    final grad = Uint8List(n);
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        int p(int dx, int dy) => g[(y + dy) * w + x + dx];
        final gx = -p(-1, -1) + p(1, -1) - 2 * p(-1, 0) + 2 * p(1, 0) - p(-1, 1) + p(1, 1);
        final gy = -p(-1, -1) - 2 * p(0, -1) - p(1, -1) + p(-1, 1) + 2 * p(0, 1) + p(1, 1);
        grad[y * w + x] = math.min(255, math.sqrt(gx * gx + gy * gy).toInt());
      }
    }
    // Otsu like the app
    final hist = List<int>.filled(256, 0);
    for (final v in g) hist[v]++;
    double sumAll = 0; for (int i = 0; i < 256; i++) sumAll += i * hist[i];
    double sumB = 0; int wB = 0; double maxV = 0; int best = 30;
    for (int t = 0; t < 256; t++) {
      wB += hist[t]; if (wB == 0) continue; final wF = n - wB; if (wF == 0) break;
      sumB += t * hist[t]; final mB = sumB / wB; final mF = (sumAll - sumB) / wF;
      final v = wB * wF * (mB - mF) * (mB - mF); if (v > maxV) { maxV = v; best = t; }
    }
    final edgeThr = (best * 0.6).clamp(20, 80).toInt();
    final gh = List<int>.filled(256, 0); for (final v in grad) gh[v]++;
    int cum = 0, gradThr = 25; for (int i = 0; i < 256; i++) { cum += gh[i]; if (cum >= (n * 0.95).toInt()) { gradThr = i.clamp(15, 80); break; } }
    final edge = Uint8List(n);
    int black = 0, halo = 0;
    for (int i = 0; i < n; i++) {
      final isLine = g[i] < edgeThr; final isGrad = grad[i] > gradThr;
      if (isLine || isGrad) edge[i] = 1;
      if (g[i] < 128) black++; else if (isGrad) halo++;
    }
    final closed = dilate(edge, w, h, 2);
    final r8 = label(edge, w, h, true);
    final r4 = label(edge, w, h, false);
    final rc = label(closed, w, h, true);
    final blackMask = Uint8List(n); for (int i = 0; i < n; i++) blackMask[i] = g[i] < 128 ? 0 : 1; // invert: label black pixels
    final bc = label(blackMask, w, h, true, minSize: 1);
    final name = f.uri.pathSegments.last.replaceAll('.gray', '').replaceAll('__', '/');
    print('$name,$w,$h,${r8.$1},${r4.$1},${rc.$1},${(r8.$2 * 100 / n).toStringAsFixed(0)},${(rc.$2 * 100 / n).toStringAsFixed(0)},${bc.$1},${(halo * 100 / n).toStringAsFixed(1)}');
  }
}

Uint8List dilate(Uint8List m, int w, int h, int r) {
  final o = Uint8List(m.length);
  for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
    if (m[y * w + x] == 0) continue;
    for (int dy = -r; dy <= r; dy++) for (int dx = -r; dx <= r; dx++) {
      if (dx * dx + dy * dy > r * r) continue;
      final nx = x + dx, ny = y + dy;
      if (nx >= 0 && ny >= 0 && nx < w && ny < h) o[ny * w + nx] = 1;
    }
  }
  return o;
}

// Counts connected components of non-blocked pixels with size >= minSize; returns (count, largestSize).
(int, int) label(Uint8List blocked, int w, int h, bool eight, {int minSize = 30}) {
  final seen = Uint8List(blocked.length);
  final stack = Int32List(blocked.length);
  int count = 0, largest = 0;
  final dxs = eight ? [1, -1, 0, 0, 1, -1, 1, -1] : [1, -1, 0, 0];
  final dys = eight ? [0, 0, 1, -1, 1, -1, -1, 1] : [0, 0, 1, -1];
  for (int s = 0; s < blocked.length; s++) {
    if (blocked[s] == 1 || seen[s] == 1) continue;
    int sp = 0, size = 0; stack[sp++] = s; seen[s] = 1;
    while (sp > 0) {
      final i = stack[--sp]; size++;
      final x = i % w, y = i ~/ w;
      for (int k = 0; k < dxs.length; k++) {
        final nx = x + dxs[k], ny = y + dys[k];
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        final j = ny * w + nx;
        if (blocked[j] == 1 || seen[j] == 1) continue;
        seen[j] = 1; stack[sp++] = j;
      }
    }
    if (size >= minSize) count++;
    largest = math.max(largest, size);
  }
  return (count, largest);
}
