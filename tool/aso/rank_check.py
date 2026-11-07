#!/usr/bin/env python3
"""Where Cobi Paint stands in App Store search, and what people type.

ranks:  the app's position in the first 200 results of each query, from
        Apple's public iTunes Search API (country tr and us). The API's
        order follows the App Store's search closely but not exactly.
hints:  the App Store's own search suggestions for a few seeds, in the
        order the store shows them (most searched first).

Usage, from the repo root:
  python3 tool/aso/rank_check.py ranks
  python3 tool/aso/rank_check.py hints
Run it before and two weeks after a name or keyword change; the numbers of
7 Nov 2026 are in plan/isim-arastirmasi-2026-11-07.html.
"""
import json
import plistlib
import sys
import time
import urllib.parse
import urllib.request

APP_ID = 6757766966
STOREFRONTS = {'tr': '143480-1,29', 'us': '143441-1,29'}
QUERIES = {
    'tr': ['boyama', 'boyama oyunu', 'boyama oyunları', 'çocuk boyama', 'çocuk boyama oyunu', 'çocuk boyama oyunları',
           'çocuklar için boyama', 'boyama kitabı', 'boyama oyunu internetsiz', 'okul öncesi boyama', '3 yaş boyama',
           'reklamsız çocuk oyunları', 'cobi'],
    'us': ['coloring', 'coloring games', 'coloring games for kids', 'coloring games for toddlers', 'kids coloring',
           'kids coloring no ads', 'toddler coloring', 'coloring book', 'cobi'],
}
SEEDS = {
    'tr': ['boyama', 'çocuk boyama', 'çocuklar için', 'okul öncesi', '3 yaş', 'reklamsız'],
    'us': ['coloring', 'coloring g', 'kids col', 'toddler'],
}


def get(url, headers=None):
    request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0', **(headers or {})})
    return urllib.request.urlopen(request, timeout=30).read()


def ranks():
    for country, terms in QUERIES.items():
        for term in terms:
            query = urllib.parse.urlencode({'term': term, 'country': country, 'entity': 'software', 'limit': 200})
            results = json.loads(get('https://itunes.apple.com/search?' + query))['results']
            rank = next((i for i, r in enumerate(results, 1) if r['trackId'] == APP_ID), None)
            print(f'{country}  {term:28s} {rank if rank else "-":>4}  (of {len(results)})')
            time.sleep(1.2)


def hints():
    for country, seeds in SEEDS.items():
        for seed in seeds:
            query = urllib.parse.urlencode({'clientApplication': 'Software', 'term': seed})
            raw = get('https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints?' + query,
                      {'User-Agent': 'AppStore/3.0 iOS/18.0', 'X-Apple-Store-Front': STOREFRONTS[country]})
            terms = [h['term'] for h in plistlib.loads(raw).get('hints', [])]
            print(f'{country}  {seed}: ' + ' · '.join(terms))
            time.sleep(1.0)


if __name__ == '__main__':
    {'ranks': ranks, 'hints': hints}.get(sys.argv[1] if len(sys.argv) > 1 else '', lambda: print(__doc__))()
