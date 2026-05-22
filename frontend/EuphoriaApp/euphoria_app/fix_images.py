import re
import random

path = 'lib/models/mock_data.dart'
with open(path, 'r', encoding='utf-8') as f:
    data = f.read()

count = 0
def repl(match):
    global count
    count += 1
    return f"'https://picsum.photos/seed/music_app_{count}/500/500'"

data = re.sub(r"'https://[^\']+'", repl, data)
with open(path, 'w', encoding='utf-8') as f:
    f.write(data)

path2 = 'lib/widgets/shared_widgets.dart'
with open(path2, 'r', encoding='utf-8') as f:
    data2 = f.read()
data2 = data2.replace('CachedNetworkImage(', 'CachedNetworkImage(fadeInDuration: Duration.zero, ')
with open(path2, 'w', encoding='utf-8') as f:
    f.write(data2)

paths = [
  'lib/screens/search_screen.dart',
  'lib/screens/playlist_detail_screen.dart',
  'lib/screens/now_playing_screen.dart',
  'lib/screens/library_screen.dart',
  'lib/screens/home_screen.dart',
  'lib/screens/artist_detail_screen.dart',
  'lib/screens/album_detail_screen.dart'
]
for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        d = f.read()
    if 'Image.network(' in d:
        if 'package:cached_network_image/cached_network_image.dart' not in d:
            d = "import 'package:cached_network_image/cached_network_image.dart';\n" + d
        d = d.replace('Image.network(', 'CachedNetworkImage(fadeInDuration: Duration.zero, imageUrl: ')
        d = re.sub(r'errorBuilder:\s*\([^)]*\)\s*=>', r'errorWidget: (_, __, ___) =>', d)
        with open(p, 'w', encoding='utf-8') as f:
            f.write(d)
