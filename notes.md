# Stuff

<https://whiteknightstudios.itch.io/free-animated-character-ghoul-zombie>
<https://whiteknightstudios.itch.io/iso>

benchmarks:

naive implementation (drawing 400 circles each frame, not using soa):

```odin
 if shouldBenchmark {
  using gameState
  tile := &tiles[8][10]
  selectedTile = tile
  tile.tower = towers[.Archer]
 }
```

with tile hitbox lines on:
Metrics{currentFps = 993.4433, minFps = 12.1828499, avgFps = 938.5551, maxFps = 1022.39038, timeElapsed = 10.0009298, framesElapsed = 9162}

off:
Metrics{currentFps = 1947.41968, minFps = 15.5596247, avgFps = 1913.0161, maxFps = 1996.80518, timeElapsed = 10.0003395, framesElapsed = 18861}

off and minFps recorded after 3 seconds in:
Metrics{currentFps = 1919.0175, minFps = 772.6781, avgFps = 1879.8447, maxFps = 1961.93848, timeElapsed = 10.000491, framesElapsed = 18527}
