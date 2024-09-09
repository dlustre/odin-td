package odinTd

import sa "core:container/small_array"
import rl "vendor:raylib"

maxMobs :: 100
maxProjectiles :: 200
maxWaves :: 100


WaveMob :: struct {
	mob:       MobKind,
	spawnTime: f32,
}

Wave :: distinct sa.Small_Array(maxMobs, WaveMob)

Level :: struct {
	startCoords, endCoords: [2]int,
	waves:                  sa.Small_Array(maxWaves, Wave),
	grid:                   string,
}

Metrics :: struct {
	currentFps, minFps, avgFps, maxFps, timeElapsed: f32,
	framesElapsed:                                   int,
}

Subtexture :: struct {
	using rect: rl.Rectangle,
	name:       string,
}

Tile :: struct {
	using r: rl.Rectangle,
	tower:   Tower,
	kind:    TileKind,
}

GameState :: struct {
	health, money, currentWave, currentWaveMob: int,
	spawnTimer:                                 f32,
	tiles:                                      [levelSize][levelSize]Tile,
	ephemeralAnimations:                        sa.Small_Array(maxProjectiles, EphemeralAnimation),
	mobs:                                       sa.Small_Array(maxMobs, AnimatedMob),
	selectedTile:                               ^Tile,
}

Tower :: struct {
	radius, damage, speed, attackTimer: f32,
	sounds:                             [SoundKind]^rl.Sound,
	projectileTexture:                  ^rl.Texture,
	kind:                               TowerKind,
	cost:                               int,
}

TileKind :: enum {
	Unknown,
	AllGrass,
	Grass,
	Road_NS,
	Road_EW,
	Road_NE,
	Road_ES,
	Road_SW,
	Road_WN,
	Road_NES,
	Road_ESW,
	Road_SWN,
	Road_WNE,
	Road_ALL,
}

TowerSegmentKind :: enum {
	Unknown,
	Bottom,
	Mid,
	Top,
}

TowerKind :: enum {
	Unknown,
	Archer,
	Wizard,
}

AnimationKind :: enum {
	Unknown,
	Idle,
	Walk,
	Death,
}

SoundKind :: enum {
	Unknown,
	Place,
	Shoot,
}

DirectionKind :: enum {
	Unknown,
	North,
	East,
	South,
	West,
}

// The direction in which the next frame in the spritemap is located.
SpritemapDirectionKind :: enum {
	Unknown,
	Right,
	Down,
}

MobKind :: enum {
	Unknown,
	SkelWarrior,
	SkelMage,
}
