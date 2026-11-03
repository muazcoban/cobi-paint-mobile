import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// barrier: 1 = line pixel, 0 = fillable
Uint8List loadBarrier(String path, {int threshold = 128}) {
  final im = img.decodePng(File(path).readAsBytesSync())!;
  final w = im.width, h = im.height;
  final out = Uint8List(w * h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = im.getPixel(x, y);
      final a = im.hasAlpha ? p.a / p.maxChannelValue : 1.0;
      final lum = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b) / p.maxChannelValue;
      final v = lum * a + (1 - a); // composite on white
      out[y * w + x] = v < threshold / 255 ? 1 : 0;
    }
  }
  _w = w;
  _h = h;
  return out;
}

int _w = 0, _h = 0;

Uint8List upscaleNearest(Uint8List src, int w, int h, int nw, int nh) {
  final out = Uint8List(nw * nh);
  for (var y = 0; y < nh; y++) {
    final sy = y * h ~/ nh;
    for (var x = 0; x < nw; x++) {
      out[y * nw + x] = src[sy * w + (x * w ~/ nw)];
    }
  }
  return out;
}

/// Two-pass union-find CCL over barrier==0 pixels. Returns (labels, count, areas)
(Int32List, int, Int32List) ccl(Uint8List barrier, int w, int h, {bool eight = false}) {
  final n = w * h;
  final labels = Int32List(n);
  final parent = Int32List(n ~/ 2 + 2);
  var next = 1;
  int find(int a) {
    while (parent[a] != a) {
      parent[a] = parent[parent[a]];
      a = parent[a];
    }
    return a;
  }

  void union(int a, int b) {
    a = find(a);
    b = find(b);
    if (a == b) return;
    if (a < b) {
      parent[b] = a;
    } else {
      parent[a] = b;
    }
  }

  for (var y = 0; y < h; y++) {
    final row = y * w;
    for (var x = 0; x < w; x++) {
      final i = row + x;
      if (barrier[i] != 0) continue;
      var l = 0;
      void take(int j) {
        final lj = labels[j];
        if (lj == 0) return;
        if (l == 0) {
          l = lj;
        } else if (lj != l) {
          union(l, lj);
        }
      }

      if (x > 0) take(i - 1);
      if (y > 0) take(i - w);
      if (eight && y > 0) {
        if (x > 0) take(i - w - 1);
        if (x < w - 1) take(i - w + 1);
      }
      if (l == 0) {
        if (next >= parent.length) throw 'too many provisional labels';
        parent[next] = next;
        l = next++;
      }
      labels[i] = l;
    }
  }
  final remap = Int32List(next);
  var count = 0;
  for (var k = 1; k < next; k++) {
    final r = find(k);
    if (r == k) remap[k] = ++count;
  }
  final areas = Int32List(count + 1);
  for (var i = 0; i < n; i++) {
    final l = labels[i];
    if (l != 0) {
      final f = remap[find(l)];
      labels[i] = f;
      areas[f]++;
    }
  }
  return (labels, count, areas);
}

/// square dilation of radius r (separable max filter)
Uint8List dilate(Uint8List b, int w, int h, int r) {
  if (r == 0) return b;
  final tmp = Uint8List(w * h), out = Uint8List(w * h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      var v = 0;
      for (var k = -r; k <= r && v == 0; k++) {
        final xx = x + k;
        if (xx >= 0 && xx < w) v = b[y * w + xx];
      }
      tmp[y * w + x] = v;
    }
  }
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      var v = 0;
      for (var k = -r; k <= r && v == 0; k++) {
        final yy = y + k;
        if (yy >= 0 && yy < h) v = tmp[yy * w + x];
      }
      out[y * w + x] = v;
    }
  }
  return out;
}

/// Grow labels into unlabeled pixels (lines + dropped tiny regions) by multi-source BFS.
void grow(Int32List labels, int w, int h) {
  final n = w * h;
  final q = Int32List(n);
  var head = 0, tail = 0;
  for (var i = 0; i < n; i++) {
    if (labels[i] != 0) q[tail++] = i;
  }
  while (head < tail) {
    final i = q[head++];
    final l = labels[i];
    final x = i % w;
    if (x > 0 && labels[i - 1] == 0) { labels[i - 1] = l; q[tail++] = i - 1; }
    if (x < w - 1 && labels[i + 1] == 0) { labels[i + 1] = l; q[tail++] = i + 1; }
    if (i >= w && labels[i - w] == 0) { labels[i - w] = l; q[tail++] = i - w; }
    if (i < n - w && labels[i + w] == 0) { labels[i + w] = l; q[tail++] = i + w; }
  }
}

int significant(Int32List areas, int minArea) {
  var c = 0;
  for (var k = 1; k < areas.length; k++) {
    if (areas[k] >= minArea) c++;
  }
  return c;
}

void main(List<String> args) {
  final mode = args[0];
  if (mode == 'audit') {
    // per-asset: significant regions with 4-conn vs 8-conn, and after closing r=1,2,3
    print('asset,w,regions8,regions4,close1,close2,close3');
    for (final path in args.skip(1)) {
      final b = loadBarrier(path);
      final w = _w, h = _h;
      final minArea = (w * h * 0.0002).ceil(); // 0.02% of image
      final s8 = significant(ccl(b, w, h, eight: true).$3, minArea);
      final s4 = significant(ccl(b, w, h).$3, minArea);
      final c = [1, 2, 3].map((r) => significant(ccl(dilate(b, w, h, r), w, h).$3, minArea)).toList();
      print('${path.split('/categories/').last},$w,$s8,$s4,${c.join(',')}');
    }
  } else {
    // timing at target resolution
    final target = int.parse(args[1]);
    final b0 = loadBarrier(args[2]);
    final b = upscaleNearest(b0, _w, _h, target, target);
    final w = target, h = target;
    for (var rep = 0; rep < 3; rep++) {
      final sw = Stopwatch()..start();
      final (labels, count, areas) = ccl(b, w, h);
      final tCcl = sw.elapsedMilliseconds;
      grow(labels, w, h);
      final tGrow = sw.elapsedMilliseconds - tCcl;
      final d = dilate(b, w, h, 3);
      final tDil = sw.elapsedMilliseconds - tCcl - tGrow;
      print('run$rep ${w}x$h ccl4=${tCcl}ms (labels=$count) grow=${tGrow}ms dilate_r3=${tDil}ms total=${sw.elapsedMilliseconds}ms');
    }
  }
}
