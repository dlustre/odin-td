package odinTd

import sa "core:container/small_array"
import "core:math/linalg"
import rl "vendor:raylib"

AnimatedMob :: struct {
	animations:         [AnimationKind]Animation,
	spritemapDirection: SpritemapDirectionKind,
	timer, scale:       f32,
	state:              AnimationKind,
	texture:            ^rl.Texture,
	deathSound:         ^rl.Sound,
	tint:               rl.Color,
	currentFrame:       int,
	using m:            Mob,
}

Mob :: struct {
	direction:                   DirectionKind,
	prev, position, next:        [2]int,
	speed, health, moveProgress: f32,
	damage, moneyDrop:           int,
}

move_mob :: proc(gameState: ^GameState, using am: ^AnimatedMob, dt: f32) {
	if state == .Death do return
	if position == nullCoords do return

	moveProgress += speed * dt

	if moveProgress >= 1 {
		prev, position = position, next
		moveProgress = 0
	}

	if position == endCoords {
		position = nullCoords
		gameState.health -= damage
		return
	}
	next, direction = find_next_road(prev, position)
}

update_mob_health :: proc(using mob: ^AnimatedMob, value: f32) {
	health = clamp(health + value, 0, 100)
}

kill_mob :: proc(gameState: ^GameState, index: int) {
	using am, ok := sa.get_ptr_safe(&gameState.mobs, index)
	defer sa.ordered_remove(&gameState.mobs, index)
	assert(ok)
	timer = 0
	tint = {}
	state = .Death

	worldPos := mob_world_pos(
		{f32(position.x), f32(position.y)},
		{f32(next.x), f32(next.y)},
		moveProgress,
	)
	// fmt.println(am)

	create_ephemeral_animation(
		gameState,
		{
			position = {
				worldPos.x + (tileWidth - animations[state].st.width) / 2,
				worldPos.y - (tileHeight * 0.25),
			},
			rotation = {},
			origin = {},
			texture = texture,
			spritemapDirection = .Right,
			worldDimensions = {animations[.Death].st.width, animations[.Death].st.width},
			duration = animations[.Death].frameDuration * f32(animations[.Death].numFrames),
			numFrames = animations[.Death].numFrames,
			tint = rl.RED,
			scale = 1.3,
			st = animations[.Death].st,
			flip = direction == .West || direction == .South,
		},
	)

	play_sound_variant_pitch(deathSound)
}

mob_world_pos :: proc(position, next: rl.Vector2, moveProgress: f32) -> rl.Vector2 {
	assert(moveProgress >= 0 && moveProgress <= 1)
	lerpedPos := linalg.lerp(position, next, moveProgress)
	x, y := tile_to_screen_space(lerpedPos.x, levelSize - 1 - lerpedPos.y)
	return {x, y}
}

draw_mob :: proc(using am: ^AnimatedMob) {
	assert(am != nil)
	worldPos := mob_world_pos(
		{f32(position.x), f32(position.y)},
		{f32(next.x), f32(next.y)},
		moveProgress,
	)

	src := animations[state].st
	src.x += f32(skelSize * currentFrame)

	dest := rl.Rectangle {
		worldPos.x + (tileWidth - src.width) / 2,
		worldPos.y - (tileHeight * 0.25),
		src.width * scale,
		src.height * scale,
	}

	// if state == .Death do fmt.println(dest)

	shadowColor := rl.BLACK
	shadowColor.xyz += 25
	shadowColor.a -= 170

	rl.DrawEllipse(
		i32(dest.x + (src.width * scale) / 1.7),
		i32(dest.y + (src.height * scale) / 1.1),
		15,
		6,
		shadowColor,
	)

	if direction == .West || direction == .South do src.width = -src.width
	rl.DrawTexturePro(texture^, src, dest, {0, 0}, 0, tint)

	draw_healthbar(am, {dest.x, dest.y - 10})
}

draw_healthbar :: proc(using am: ^AnimatedMob, pos: rl.Vector2) {
	assert(health >= 0)
	if health == 0 do return
	widthFactor: f32 = 0.7
	rl.DrawRectangleV(pos, {f32(100) * widthFactor, 7}, rl.RED)
	rl.DrawRectangleV(pos, {f32(health) * widthFactor, 7}, rl.GREEN)
}

create_animated_mob :: proc(using gs: ^GameState, a: AnimatedMob) {
	sa.append(&mobs, a)
}
