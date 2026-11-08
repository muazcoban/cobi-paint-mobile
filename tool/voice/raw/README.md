# Ham ses kayıtları

Bu klasörün içeriği depoya girmez (`.gitignore`: `tool/voice/raw/*`); yalnız bu dosya izlenir.
İşlenmiş klipler `assets/voice/` altına yazılır ve depoya onlar girer.

Düzen:

```
tool/voice/raw/
  tr/<anahtar>.m4a   Türkçe kayıtlar
  en/<anahtar>.m4a   İngilizce kayıtlar
```

- Anahtar, `tool/voice/README.md` tablolarındaki addır: `fill`, `color_3`, `category_animals`,
  `word_sun`. Tabloda olmayan bir ad betik tarafından uyarıyla atlanır.
- Uzantı `m4a` (iPhone Sesli Notlar), `wav`, `aiff`, `mp3`, `caf` ya da `flac` olabilir. Bir anahtar
  için tek dosya bulunur; iki dosya varsa betik ikisini de işlemez.
- Her klip ayrı dosyadır; kenarlardaki sessizliği betik kırpar, kaydı geniş bırakmak sorun değildir.
- Kayıt kuralları ve sırası: `tool/voice/kayit-rehberi.md`. İşleme: `python3 tool/voice/process_clips.py`.
