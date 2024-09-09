package odinTd

import "base:runtime"
import sa "core:container/small_array"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:reflect"
import "core:slice"
import "core:strings"
import rl "vendor:raylib"

shouldBenchmark :: true
showTileLines :: true
benchmarkDuration :: -1
game_should_run :: proc(timeElapsed: f32) -> bool {
	return (benchmarkDuration == -1 || timeElapsed < benchmarkDuration) && !rl.WindowShouldClose()
}

targetFps :: 0
configFlags: rl.ConfigFlags : {}
_configFlags: rl.ConfigFlags : {.VSYNC_HINT}

@(rodata)
landscapeSubtextures := [?]Subtexture {
	{name = "crystals_1", x = 1720, y = 198, width = 132, height = 112},
	{name = "crystals_2", x = 1852, y = 114, width = 132, height = 121},
	{name = "crystals_3", x = 0, y = 297, width = 133, height = 127},
	{name = "crystals_4", x = 1852, y = 0, width = 132, height = 114},
	{name = "landscape_00", x = 1192, y = 99, width = 132, height = 99},
	{name = "landscape_01", x = 1061, y = 0, width = 132, height = 99},
	{name = "landscape_02", x = 1060, y = 396, width = 132, height = 99},
	{name = "landscape_03", x = 1060, y = 297, width = 132, height = 99},
	{name = "landscape_04", x = 1060, y = 198, width = 132, height = 99},
	{name = "landscape_05", x = 1060, y = 99, width = 132, height = 99},
	{name = "landscape_06", x = 929, y = 0, width = 132, height = 99},
	{name = "landscape_07", x = 928, y = 329, width = 132, height = 99},
	{name = "landscape_08", x = 1852, y = 235, width = 132, height = 115},
	{name = "landscape_09", x = 1720, y = 409, width = 132, height = 99},
	{name = "landscape_10", x = 1720, y = 310, width = 132, height = 99},
	{name = "landscape_11", x = 1456, y = 198, width = 132, height = 99},
	{name = "landscape_12", x = 796, y = 313, width = 132, height = 99},
	{name = "landscape_13", x = 796, y = 214, width = 132, height = 99},
	{name = "landscape_14", x = 665, y = 115, width = 132, height = 99},
	{name = "landscape_15", x = 796, y = 412, width = 132, height = 99},
	{name = "landscape_16", x = 664, y = 317, width = 132, height = 99},
	{name = "landscape_17", x = 664, y = 234, width = 132, height = 83},
	{name = "landscape_18", x = 665, y = 0, width = 132, height = 115},
	{name = "landscape_19", x = 532, y = 234, width = 132, height = 99},
	{name = "landscape_20", x = 532, y = 333, width = 132, height = 115},
	{name = "landscape_21", x = 0, y = 424, width = 132, height = 83},
	{name = "landscape_22", x = 928, y = 115, width = 132, height = 115},
	{name = "landscape_23", x = 797, y = 0, width = 132, height = 115},
	{name = "landscape_24", x = 1192, y = 198, width = 132, height = 99},
	{name = "landscape_25", x = 1192, y = 297, width = 132, height = 99},
	{name = "landscape_26", x = 1192, y = 396, width = 132, height = 99},
	{name = "landscape_27", x = 1324, y = 225, width = 132, height = 115},
	{name = "landscape_28", x = 1193, y = 0, width = 132, height = 99},
	{name = "landscape_29", x = 1325, y = 0, width = 132, height = 99},
	{name = "landscape_30", x = 1456, y = 99, width = 132, height = 99},
	{name = "landscape_31", x = 1324, y = 340, width = 132, height = 99},
	{name = "landscape_32", x = 928, y = 230, width = 132, height = 99},
	{name = "landscape_33", x = 1588, y = 99, width = 132, height = 99},
	{name = "landscape_34", x = 1588, y = 297, width = 132, height = 99},
	{name = "landscape_35", x = 1588, y = 396, width = 132, height = 99},
	{name = "landscape_36", x = 1589, y = 0, width = 132, height = 99},
	{name = "landscape_37", x = 0, y = 198, width = 133, height = 99},
	{name = "landscape_38", x = 1720, y = 99, width = 132, height = 99},
	{name = "landscape_39", x = 1457, y = 0, width = 132, height = 99},
	{name = "rocks_1", x = 0, y = 0, width = 133, height = 99},
	{name = "rocks_2", x = 0, y = 99, width = 133, height = 99},
	{name = "rocks_3", x = 133, y = 0, width = 133, height = 102},
	{name = "rocks_4", x = 133, y = 102, width = 133, height = 102},
	{name = "rocks_5", x = 133, y = 204, width = 133, height = 99},
	{name = "rocks_6", x = 133, y = 303, width = 133, height = 99},
	{name = "rocks_7", x = 1588, y = 198, width = 132, height = 99},
	{name = "rocks_8", x = 133, y = 402, width = 133, height = 99},
	{name = "trees_1", x = 266, y = 241, width = 133, height = 111},
	{name = "trees_10", x = 1456, y = 297, width = 132, height = 130},
	{name = "trees_11", x = 266, y = 0, width = 133, height = 118},
	{name = "trees_12", x = 266, y = 118, width = 133, height = 123},
	{name = "trees_2", x = 399, y = 127, width = 133, height = 121},
	{name = "trees_3", x = 266, y = 352, width = 133, height = 113},
	{name = "trees_4", x = 399, y = 0, width = 133, height = 127},
	{name = "trees_5", x = 1324, y = 99, width = 132, height = 126},
	{name = "trees_6", x = 399, y = 248, width = 133, height = 124},
	{name = "trees_7", x = 399, y = 372, width = 133, height = 121},
	{name = "trees_8", x = 532, y = 0, width = 133, height = 118},
	{name = "trees_9", x = 532, y = 118, width = 133, height = 116},
}

@(rodata)
greyTowersSubtextures := [?]Subtexture {
	{name = "tower_00", x = 187, y = 150, width = 89, height = 100},
	{name = "tower_01", x = 447, y = 235, width = 79, height = 72},
	{name = "tower_02", x = 684, y = 72, width = 79, height = 72},
	{name = "tower_03", x = 0, y = 232, width = 95, height = 76},
	{name = "tower_04", x = 0, y = 156, width = 95, height = 76},
	{name = "tower_05", x = 103, y = 75, width = 90, height = 75},
	{name = "tower_06", x = 103, y = 0, width = 90, height = 75},
	{name = "tower_07", x = 0, y = 0, width = 103, height = 78},
	{name = "tower_08", x = 526, y = 217, width = 79, height = 72},
	{name = "tower_09", x = 0, y = 78, width = 103, height = 78},
	{name = "tower_10", x = 93, y = 308, width = 92, height = 75},
	{name = "tower_11", x = 685, y = 286, width = 79, height = 72},
	{name = "tower_12", x = 606, y = 307, width = 79, height = 70},
	{name = "tower_13", x = 93, y = 383, width = 92, height = 75},
	{name = "tower_14", x = 95, y = 156, width = 92, height = 75},
	{name = "tower_15", x = 447, y = 156, width = 79, height = 79},
	{name = "tower_16", x = 763, y = 149, width = 79, height = 72},
	{name = "tower_17", x = 763, y = 79, width = 79, height = 70},
	{name = "tower_18", x = 363, y = 229, width = 84, height = 73},
	{name = "tower_19", x = 95, y = 231, width = 92, height = 75},
	{name = "tower_20", x = 362, y = 424, width = 86, height = 74},
	{name = "tower_21", x = 276, y = 103, width = 87, height = 82},
	{name = "tower_22", x = 684, y = 214, width = 79, height = 72},
	{name = "tower_23", x = 684, y = 144, width = 79, height = 70},
	{name = "tower_24", x = 363, y = 302, width = 84, height = 73},
	{name = "tower_25", x = 610, y = 0, width = 79, height = 72},
	{name = "tower_26", x = 363, y = 82, width = 86, height = 74},
	{name = "tower_27", x = 274, y = 350, width = 89, height = 74},
	{name = "tower_28", x = 605, y = 228, width = 79, height = 79},
	{name = "tower_29", x = 605, y = 149, width = 79, height = 79},
	{name = "tower_30", x = 605, y = 79, width = 79, height = 70},
	{name = "tower_31", x = 363, y = 156, width = 84, height = 73},
	{name = "tower_32", x = 527, y = 433, width = 79, height = 72},
	{name = "tower_33", x = 527, y = 361, width = 79, height = 72},
	{name = "tower_34", x = 185, y = 306, width = 89, height = 74},
	{name = "tower_35", x = 185, y = 380, width = 89, height = 98},
	{name = "tower_36", x = 282, y = 0, width = 87, height = 82},
	{name = "tower_37", x = 369, y = 0, width = 83, height = 73},
	{name = "tower_38", x = 449, y = 73, width = 79, height = 72},
	{name = "tower_39", x = 448, y = 386, width = 79, height = 72},
	{name = "tower_40", x = 764, y = 221, width = 78, height = 72},
	{name = "tower_41", x = 193, y = 0, width = 89, height = 103},
	{name = "tower_42", x = 763, y = 0, width = 79, height = 79},
	{name = "tower_43", x = 526, y = 289, width = 79, height = 72},
	{name = "tower_44", x = 685, y = 430, width = 79, height = 72},
	{name = "tower_45", x = 685, y = 358, width = 79, height = 72},
	{name = "tower_46", x = 0, y = 308, width = 93, height = 98},
	{name = "tower_47", x = 531, y = 0, width = 79, height = 79},
	{name = "tower_48", x = 606, y = 377, width = 79, height = 72},
	{name = "tower_49", x = 526, y = 145, width = 79, height = 72},
	{name = "tower_50", x = 0, y = 406, width = 93, height = 98},
	{name = "tower_51", x = 274, y = 424, width = 88, height = 82},
	{name = "tower_52", x = 452, y = 0, width = 79, height = 72},
	{name = "tower_53", x = 274, y = 250, width = 89, height = 100},
	{name = "tower_54", x = 447, y = 307, width = 79, height = 79},
}

skelSize :: 48

@(rodata)
skelWarriorSubtextures := [?]Subtexture {
	{name = "idle", x = 0, y = skelSize * 0, width = skelSize, height = skelSize},
	{name = "attack", x = 0, y = skelSize * 1, width = skelSize, height = skelSize},
	{name = "walk", x = 0, y = skelSize * 2, width = skelSize, height = skelSize},
	{name = "hurt", x = 0, y = skelSize * 3, width = skelSize, height = skelSize},
	{name = "death", x = 0, y = skelSize * 4, width = skelSize, height = skelSize},
}

@(rodata)
skelMageSubtextures := [?]Subtexture {
	{name = "idle", x = 0, y = skelSize * 0, width = skelSize, height = skelSize},
	{name = "attack", x = 0, y = skelSize * 1, width = skelSize, height = skelSize},
	{name = "walk", x = 0, y = skelSize * 2, width = skelSize, height = skelSize},
	{name = "hurt", x = 0, y = skelSize * 3, width = skelSize, height = skelSize},
	{name = "death", x = 0, y = skelSize * 4, width = skelSize, height = skelSize},
}

// todo: these should be constants but odin breaks when they are. change when fixed
trollSubtexture := Subtexture {
	width  = 72,
	height = 90,
}

laserSubtexture := Subtexture {
	width  = 256,
	height = 64,
}

grass1 :=
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	"..########......" +
	"..#............." +
	"..#..#########.." +
	"..#..#.......#.." +
	"..#..#.......#.." +
	"..####.......#.." +
	"........######.." +
	"........#......." +
	"........###....." +
	"..........#....." +
	""
grassStraight :=
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".....#...#......" +
	".....#...#......" +
	"...###...#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	".........#......" +
	""


levelMap := grass1

tileWidth, tileHeight :: 128, 96
tileSize :: rl.Vector2{tileWidth, tileHeight}
levelSize :: 16
startCoords :: [2]int{9, 0}
endCoords :: [2]int{10, 15}
_endCoords :: [2]int{9, 15}

// Null identifier. Intended for dead mobs or unselecting a tile.
nullCoords :: [2]int{-1, -1}

coords_to_road_kind :: proc(x, y: int) -> (roadKind: TileKind) {
	N, E, S, W: bool

	if x == 0 do W = true
	if x == levelSize - 1 do E = true
	if y == 0 do N = true
	if y == levelSize - 1 do S = true

	if x + 1 < levelSize && levelMap[levelSize * y + x + 1] == '#' do E = true
	if x - 1 < levelSize && levelMap[levelSize * y + x - 1] == '#' do W = true
	if y + 1 < levelSize && levelMap[levelSize * (y + 1) + x] == '#' do S = true
	if y - 1 >= 0 && levelMap[levelSize * (y - 1) + x] == '#' do N = true

	switch {
	case N && E && S && W:
		roadKind = .Road_ALL
	case N && E && S:
		roadKind = .Road_NES
	case N && E && W:
		roadKind = .Road_WNE
	case E && W && S:
		roadKind = .Road_ESW
	case S && W && N:
		roadKind = .Road_SWN

	case N && S:
		roadKind = .Road_NS
	case N && E:
		roadKind = .Road_NE
	case N && W:
		roadKind = .Road_WN
	case S && E:
		roadKind = .Road_ES
	case S && W:
		roadKind = .Road_SW
	case E && W:
		roadKind = .Road_EW
	}

	return
}

tile_to_screen_space :: proc(u, v: f32) -> (x, y: f32) {
	x = (u + v) * 0.5
	y = (u - v) * 0.25
	x *= tileWidth
	y *= tileWidth
	return
}

find_next_road :: proc(prev: [2]int, cur: [2]int) -> (next: [2]int, direction: DirectionKind) {
	adjacents := [DirectionKind][2]int {
		.Unknown = {},
		.North   = {cur.x, cur.y - 1},
		.West    = {cur.x - 1, cur.y},
		.South   = {cur.x, cur.y + 1},
		.East    = {cur.x + 1, cur.y},
	}

	for a, d in adjacents {
		if a == prev do continue
		if a.x < 0 || a.x >= levelSize do continue
		if a.y < 0 || a.y >= levelSize do continue
		if coords_to_char(a.x, a.y) == '#' || a == endCoords do return a, d
	}

	assert(false)
	return {}, {}
}

coords_to_char :: proc(x, y: int) -> u8 {
	return levelMap[levelSize * y + x]
}

closest_mob_index :: proc(
	using gameState: ^GameState,
	using tile: ^Tile,
) -> (
	index: int,
	distance: f32,
) {
	assert(tower.kind != .Unknown)

	context.user_ptr = &rl.Vector2{(x + x + width) / 2, y}

	distances := slice.mapper(sa.slice(&mobs), proc(using am: AnimatedMob) -> f32 {
		towerCenter := cast(^rl.Vector2)(context.user_ptr)
		mobWorldPos := mob_world_pos(
			{f32(position.x), f32(position.y)},
			{f32(next.x), f32(next.y)},
			moveProgress,
		)
		mobWorldPos.x += (tileWidth - animations[state].st.width)
		return linalg.distance(towerCenter^, mobWorldPos)
	})

	minIndex := slice.min_index(distances)

	// fmt.println(minIndex, distances)

	return minIndex, minIndex == -1 ? -1 : distances[minIndex]
}

tower_attack_mob :: proc(gameState: ^GameState, using tile: ^Tile, mobIndex: int, distance: f32) {
	using am, ok := sa.get_ptr_safe(&gameState.mobs, mobIndex)
	assert(ok)
	assert(am != nil)
	assert(tower.kind != .Unknown)
	assert(position != nullCoords)
	assert(state != .Death)
	// if position == nullCoords do return
	// if state == .Death do return

	mobWorldPos := mob_world_pos(
		{f32(position.x), f32(position.y)},
		{f32(next.x), f32(next.y)},
		moveProgress,
	)
	mobWorldPos.x += (tileWidth - animations[state].st.width)
	towerCenter := rl.Vector2{(x + x + width) / 2, y}
	// rl.DrawLineEx(towerCenter, mobWorldPos, 20, rl.PINK)
	if distance <= tower.radius {
		for i in 0 ..= 400 do rl.DrawCircleLinesV(towerCenter, tower.radius - f32(i) * 0.01, rl.RED)

		position := towerCenter
		position.y -= laserSubtexture.height / 2

		create_ephemeral_animation(
			gameState,
			{
				position           = position,
				rotation           = math.to_degrees(
					math.atan2(mobWorldPos.y - position.y, mobWorldPos.x - position.x),
				),
				texture            = tower.projectileTexture,
				spritemapDirection = .Down,
				worldDimensions    = {distance + 10, laserSubtexture.height},
				duration           = 0.15,
				numFrames          = 7,
				tint               = rl.WHITE,
				// tint = rl.RED,
				scale              = 1,
				st                 = laserSubtexture,
				origin             = {0, laserSubtexture.rect.height / 2},
			},
		)
		rl.DrawCircleLinesV(towerCenter, 20, rl.RED)
		rl.PlaySound(tower.sounds[.Shoot]^)
		update_mob_health(am, -tower.damage)
		if health == 0 {
			kill_mob(gameState, mobIndex)
			update_money(gameState, am.moneyDrop)
		}
	}
}

draw_hud :: proc(using gs: ^GameState, using level: ^Level) {
	rl.DrawText(
		strings.clone_to_cstring(
			fmt.tprint("wave ", currentWave + 1, "/", sa.len(waves), sep = ""),
		),
		100,
		rl.GetScreenHeight() - 300,
		30,
		rl.RED,
	)
	rl.DrawText(
		strings.clone_to_cstring(
			fmt.tprint("mobs left: ", sa.len(sa.get(waves, currentWave)) - currentWaveMob),
		),
		100,
		rl.GetScreenHeight() - 200,
		30,
		rl.RED,
	)
	rl.DrawText(
		strings.clone_to_cstring(fmt.tprint(health)),
		100,
		rl.GetScreenHeight() - 100,
		50,
		rl.RED,
	)
	rl.DrawText(
		strings.clone_to_cstring(fmt.tprint(money)),
		250,
		rl.GetScreenHeight() - 100,
		50,
		rl.GREEN,
	)
}

draw_metrics :: proc(using m: Metrics) {
	for field, index in reflect.struct_fields_zipped(type_of(m)) {
		rl.DrawText(
			strings.clone_to_cstring(
				fmt.tprint(field.name, ": ", reflect.struct_field_value(m, field)),
			),
			50,
			50 + i32(30 * index),
			20,
			rl.BLACK,
		)
	}
}

play_sound_variant_pitch :: proc(sound: ^rl.Sound) {
	context = runtime.default_context()
	variantArray := [?]f32{-0.04, -0.025, 0, 0.025, 0.04}
	rl.SetSoundPitch(sound^, 1 + rand.choice(variantArray[:]))
	rl.PlaySound(sound^)
}

check_tile_collision :: proc(point: rl.Vector2, using t: ^Tile) -> bool {
	points := tile_to_hitbox(t)

	return(
		rl.CheckCollisionPointTriangle(point, points[0], points[1], points[3]) ||
		rl.CheckCollisionPointTriangle(point, points[0], points[2], points[3]) \
	)
}

update_money :: proc(using gs: ^GameState, value: int) {
	money += value
}

// * sucks, but I'm not sure if there's anything I can do about this
tile_to_hitbox :: proc(using t: ^Tile) -> [4]rl.Vector2 {
	return {
		{t.x + (tileWidth / 1.93), t.y + 3}, // Top
		{t.x + 5, t.y + (tileHeight / 2.75)}, // Left
		{t.x + tileWidth, t.y + (tileHeight / 2.75)}, // Right
		{t.x + (tileWidth / 1.93), t.y + (tileHeight / 1.45)}, // Bottom
	}
}

place_tower :: proc(using gs: ^GameState, using t: ^Tile, newTower: Tower) {
	assert(tower.kind == .Unknown)
	update_money(gs, -newTower.cost)
	tower = newTower
	selectedTile = selectedTile == t ? nil : t
	play_sound_variant_pitch(tower.sounds[.Place])
}

wave_mob :: proc(using l: ^Level, wave, mob: int) -> WaveMob {
	w := sa.get(waves, wave)
	return sa.get(w, mob)
}

main :: proc() {
	assert(len(levelMap) == levelSize * levelSize)

	// for a, i in TileKind do fmt.println(a, i)

	rl.SetTraceLogLevel(.ERROR)
	rl.SetConfigFlags(configFlags)
	rl.SetTargetFPS(targetFps)

	rl.InitWindow(1360, 768, "LeGame");defer rl.CloseWindow()
	rl.InitAudioDevice();defer rl.CloseAudioDevice()

	placeArcher := rl.LoadSound("place-archer.wav");defer rl.UnloadSound(placeArcher)
	placeWizard := rl.LoadSound("place-wizard.wav");defer rl.UnloadSound(placeWizard)
	shootArcher := rl.LoadSound("shoot-archer.wav");defer rl.UnloadSound(shootArcher)
	shootWizard := rl.LoadSound("shoot-wizard.wav");defer rl.UnloadSound(shootWizard)
	deathSkelWarrior := rl.LoadSound(
		"death-skel-warrior.wav",
	);defer rl.UnloadSound(deathSkelWarrior)
	deathSkelMage := rl.LoadSound("death-skel-mage.wav");defer rl.UnloadSound(deathSkelMage)

	rl.SetSoundVolume(placeWizard, 0.6)
	rl.SetSoundVolume(shootArcher, 0.5)
	rl.SetSoundVolume(shootWizard, 0.3)

	landscape := rl.LoadTexture("landscape_sheet.png");defer rl.UnloadTexture(landscape)
	greyTowers := rl.LoadTexture("towers_grey_sheet.png");defer rl.UnloadTexture(greyTowers)
	troll := rl.LoadTexture("troll_1.png");defer rl.UnloadTexture(troll)
	skelWarrior := rl.LoadTexture("skeleton-warrior.png");defer rl.UnloadTexture(skelWarrior)
	skelMage := rl.LoadTexture("skeleton-mage.png");defer rl.UnloadTexture(skelMage)
	laser := rl.LoadTexture("laser.png");defer rl.UnloadTexture(laser)

	landscapeMap := make(map[string]Subtexture);defer delete(landscapeMap)
	greyTowersMap := make(map[string]Subtexture);defer delete(greyTowersMap)
	skelWarriorMap := make(map[string]Subtexture);defer delete(skelWarriorMap)
	skelMageMap := make(map[string]Subtexture);defer delete(skelMageMap)

	for st in landscapeSubtextures do landscapeMap[st.name] = st
	for st in greyTowersSubtextures do greyTowersMap[st.name] = st
	for st in skelWarriorSubtextures do skelWarriorMap[st.name] = st
	for st in skelMageSubtextures do skelMageMap[st.name] = st

	landscapeTiles := [TileKind]Subtexture {
		.Unknown  = {},
		.AllGrass = landscapeMap["landscape_13"],
		.Grass    = landscapeMap["landscape_28"],
		.Road_NS  = landscapeMap["landscape_29"],
		.Road_EW  = landscapeMap["landscape_32"],
		.Road_NE  = landscapeMap["landscape_34"],
		.Road_ES  = landscapeMap["landscape_31"],
		.Road_SW  = landscapeMap["landscape_35"],
		.Road_WN  = landscapeMap["landscape_39"],
		.Road_NES = landscapeMap["landscape_06"],
		.Road_ESW = landscapeMap["landscape_10"],
		.Road_SWN = landscapeMap["landscape_14"],
		.Road_WNE = landscapeMap["landscape_11"],
		.Road_ALL = landscapeMap["landscape_30"],
	}

	// greyTowerTiles := [TowerSegmentKind]Subtexture {
	// 	.Unknown = {},
	// 	.Bottom  = greyTowersMap["tower_09"],
	// 	.Mid     = greyTowersMap["tower_45"],
	// 	.Top     = greyTowersMap["tower_29"],
	// }

	towers := [TowerKind]Tower {
		.Unknown = {},
		.Archer = Tower {
			kind = .Archer,
			cost = 100,
			damage = 10,
			radius = 200,
			speed = 0.2,
			projectileTexture = &laser,
			sounds = {.Unknown = {}, .Place = &placeArcher, .Shoot = &shootArcher},
		},
		.Wizard = Tower {
			kind = .Wizard,
			cost = 250,
			damage = 25,
			radius = 300,
			speed = 2,
			projectileTexture = &laser,
			sounds = {.Unknown = {}, .Place = &placeWizard, .Shoot = &shootWizard},
		},
	}

	// Height-change multipliers since tower segments are different heights (hacky).
	segmentOffsets := [TowerSegmentKind]f32 {
		.Unknown = {},
		.Bottom  = 0.2,
		.Mid     = 0.5,
		.Top     = 0.89,
	}

	camera := rl.Camera2D {
		zoom = 1,
	}

	wave1: Wave

	for _ in 0 ..< 10 {
		sa.push_back(&wave1, WaveMob{.SkelWarrior, 0.5})
		sa.push_back(&wave1, WaveMob{.SkelMage, 0.5})
	}

	level := Level {
		startCoords = startCoords,
		endCoords   = endCoords,
		waves       = {},
		grid        = levelMap,
	}

	sa.append(&level.waves, wave1)

	gameState := GameState {
		money        = 300,
		health       = 100,
		selectedTile = nil,
	}

	towerTextures := [TowerKind][3]Subtexture {
		.Unknown = {},
		.Archer  = {
			greyTowersMap["tower_09"],
			greyTowersMap["tower_45"],
			greyTowersMap["tower_29"],
		},
		.Wizard  = {
			greyTowersMap["tower_09"],
			greyTowersMap["tower_45"],
			greyTowersMap["tower_53"],
		},
	}

	selectCircleRadius: f32 = 0

	metrics := Metrics {
		minFps = max(f32),
		maxFps = 0,
		avgFps = 0,
	}

	if shouldBenchmark {
		using gs := &gameState
		tile := &tiles[8][10]
		selectedTile = tile
		tile.tower = towers[.Archer]
	}

	enumeratedMobs := [MobKind]AnimatedMob {
		.Unknown = {},
		.SkelWarrior = {
			// AnimatedMob
			state = .Walk,
			texture = &skelWarrior,
			tint = rl.WHITE,
			deathSound = &deathSkelWarrior,
			scale = 1.3,
			animations = {
				.Unknown = {},
				.Idle = {},
				.Walk = {numFrames = 6, st = skelWarriorMap["walk"], frameDuration = 0.05},
				.Death = {numFrames = 12, st = skelWarriorMap["death"], frameDuration = 0.05},
			},
			// Mob
			prev = {},
			position = startCoords,
			next = {9, 1},
			speed = 2,
			health = 100,
			damage = 1,
			moneyDrop = 5,
		},
		.SkelMage = {
			// AnimatedMob
			state = .Walk,
			texture = &skelMage,
			tint = rl.WHITE,
			deathSound = &deathSkelMage,
			scale = 1.3,
			animations = {
				.Unknown = {},
				.Idle = {},
				.Walk = {numFrames = 6, st = skelMageMap["walk"], frameDuration = 0.1},
				.Death = {numFrames = 20, st = skelMageMap["death"], frameDuration = 0.05},
			},
			// Mob
			prev = {},
			position = startCoords,
			next = {9, 1},
			speed = 1,
			health = 100,
			damage = 1,
			moneyDrop = 5,
		},
	}

	for game_should_run(metrics.timeElapsed) {
		using g := &gameState
		free_all(context.temp_allocator)
		rl.BeginDrawing();defer rl.EndDrawing()
		rl.ClearBackground({128, 200, 255, 255})

		r := rand.create(2639)
		context.random_generator = rand.default_random_generator(&r)

		dt := rl.GetFrameTime()
		if dt > 0 {
			using m := &metrics
			timeElapsed += dt
			framesElapsed += 1
			currentFps = 1 / dt

			avgFps += currentFps

			if timeElapsed > 3 do minFps = min(currentFps, minFps)
			maxFps = max(currentFps, maxFps)
		}

		if sa.len(mobs) != 0 do for index in 0 ..< sa.len(mobs) {
			mob, ok := sa.get_ptr_safe(&mobs, index)
			assert(ok)
			move_mob(&gameState, mob, dt)
		}

		rl.BeginMode2D(camera)

		mouseWorldPos := rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)

		{
			using c := &camera
			camDelta: rl.Vector2
			if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) do camDelta.x += 1
			if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do camDelta.x -= 1
			if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) do camDelta.y -= 1
			if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) do camDelta.y += 1
			offset += linalg.normalize0(camDelta) * tileSize * dt * 5

			wheel := rl.GetMouseWheelMove()
			if wheel != 0 {
				offset = rl.GetMousePosition()
				target = mouseWorldPos

				scaleFactor := 1 + (0.25 * abs(wheel))
				if wheel < 0 do scaleFactor = 1 / scaleFactor
				zoom = clamp(zoom * scaleFactor, 0.5, 5)
			}
		}


		for j := levelSize - 1; j >= 0; j -= 1 {
			for i := 0; i < levelSize; i += 1 {
				tile := &tiles[i][j]
				x := i
				y := levelSize - 1 - j
				tileChar := coords_to_char(x, y)
				switch tileChar {
				case '.':
					tile.kind = .Grass
				case '#':
					tile.kind = coords_to_road_kind(x, y)
				}

				yOffset: f32 = 0
				subtex := landscapeTiles[tile.kind]
				if tile.kind == .Grass {
					switch rand.int_max(5) {
					case 1:
						subtex = landscapeMap["trees_6"]
						yOffset = -25
					}
				}

				src := subtex.rect
				dest := src
				dest.x, dest.y = tile_to_screen_space(f32(i), f32(j))

				tile.r = dest

				colors := [?]rl.Color{rl.RED, rl.GREEN, rl.BLUE, rl.YELLOW}

				dest.y += yOffset

				tint := rl.WHITE

				if tileChar == '.' && check_tile_collision(mouseWorldPos, tile) {
					if rl.IsMouseButtonPressed(.LEFT) {
						if tile.tower.kind == .Unknown {
							if money - towers[.Archer].cost >= 0 {
								place_tower(&gameState, tile, towers[.Archer])
								selectCircleRadius = 0
							}
						}
					}
					if rl.IsMouseButtonPressed(.RIGHT) {
						if tile.tower.kind == .Unknown {
							if money - towers[.Wizard].cost >= 0 {
								place_tower(&gameState, tile, towers[.Wizard])
								selectCircleRadius = 0
							}
						}
					}
					// dest.y -= 5
					tint = rl.RAYWHITE
					tint.xyz -= 30
				}
				// tint.a -= 100
				rl.DrawTexturePro(landscape, src, dest, {0, 0}, 0, tint)

				if showTileLines {
					points := tile_to_hitbox(tile)
					rl.DrawLineV(points[0], points[1], rl.RED)
					rl.DrawLineV(points[0], points[2], rl.GREEN)
					rl.DrawLineV(points[2], points[3], rl.BLUE)
					rl.DrawLineV(points[3], points[1], rl.YELLOW)
					for p, index in points do rl.DrawCircleV(p, 1, colors[index])
				}

				for subtexture, index in towerTextures[tile.tower.kind] {
					using st := subtexture
					worldX, worldY := tile_to_screen_space(f32(i), f32(j))
					towerCoords := rl.Rectangle {
						worldX + (src.width - width) / 2,
						worldY - (tileHeight * segmentOffsets[TowerSegmentKind(index + 1)]),
						width,
						height,
					}
					rl.DrawTexturePro(greyTowers, st, towerCoords, {0, 0}, 0, tint)
				}
			}
		}

		{
			spawnTimer += dt
			using wm := wave_mob(&level, currentWave, currentWaveMob)
			if spawnTimer > spawnTime {
				defer {
					spawnTimer = 0
					currentWaveMob += 1
					if currentWaveMob == sa.len(sa.get(level.waves, currentWave)) do currentWaveMob = 0
				}
				create_animated_mob(&gameState, enumeratedMobs[mob])
			}
		}

		if selectedTile != nil {
			using s := selectedTile
			towerCenter := rl.Vector2{(x + x + width) / 2, y}
			color := rl.WHITE
			color.a = 5
			for i in 0 ..= 200 do rl.DrawCircleLinesV(towerCenter, selectCircleRadius - f32(i) * 0.01, color)
		}

		if sa.len(mobs) != 0 do for index in 0 ..< sa.len(mobs) {
			using mob, ok := sa.get_ptr_safe(&mobs, index)
			assert(ok)
			timer += dt

			if timer > animations[.Walk].frameDuration {
				defer timer = 0
				currentFrame += 1

				if currentFrame == animations[state].numFrames {
					if state == .Death do position = nullCoords
					currentFrame = 0
				}
			}

			st := animations[state].st
			st.x += f32(skelSize * currentFrame)

			if position != nullCoords do draw_mob(mob)
		}

		for index in 0 ..< sa.len(ephemeralAnimations) {
			using ea, ok := sa.get_ptr_safe(&ephemeralAnimations, index)
			assert(ok)
			// fmt.println(ea^)
			timer += dt

			if timer > ea.duration {
				tint = {}
				sa.unordered_remove(&ephemeralAnimations, index)
			}

			draw_ephemeral_animation(ea)
		}

		for j in 0 ..< levelSize do for i in 0 ..< levelSize {
			using tile := &tiles[i][j]
			if tower.kind == .Unknown do continue
			tower.attackTimer += dt
			if tower.attackTimer > tower.speed {
				if sa.len(mobs) == 0 do continue
				minIndex, distance := closest_mob_index(&gameState, tile)
				if distance <= tower.radius do tower_attack_mob(&gameState, tile, minIndex, distance)
				tower.attackTimer = 0
			}
		}

		rl.EndMode2D()

		draw_hud(&gameState, &level)
		draw_metrics(metrics)

		selectCircleRadius = clamp(
			selectCircleRadius + 2000 * dt,
			0,
			selectedTile == nil ? 0 : selectedTile.tower.radius,
		)
	}

	metrics.avgFps /= f32(metrics.framesElapsed)
	fmt.println(metrics)

}
