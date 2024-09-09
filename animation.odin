package odinTd

import sa "core:container/small_array"
import rl "vendor:raylib"

EphemeralAnimation :: struct {
	duration, timer, scale, rotation: f32,
	spritemapDirection:               SpritemapDirectionKind,
	position, worldDimensions:        rl.Vector2,
	texture:                          ^rl.Texture,
	tint:                             rl.Color,
	origin:                           rl.Vector2,
	using a:                          Animation,
	flip:                             bool,
}

Animation :: struct {
	frameDuration: f32,
	numFrames:     int,
	st:            Subtexture,
}

create_ephemeral_animation :: proc(using gs: ^GameState, e: EphemeralAnimation) {
	// fmt.println(e)
	sa.append(&ephemeralAnimations, e)
}

draw_ephemeral_animation :: proc(using ea: ^EphemeralAnimation) {
	// from 0 to 1, e.g 0.8

	animationProgress := timer / duration
	// fmt.println(timer, duration, animationProgress)

	// 6 * 0.8 = 4.8. Then round. 4.8 -> 5
	currentFrame := int(f32(numFrames) * animationProgress)

	// if spritemapDirection == .Right do fmt.println(currentFrame)

	source := st

	assert(spritemapDirection != .Unknown)

	switch spritemapDirection {
	case .Unknown:
	case .Right:
		source.x += st.width * f32(currentFrame)
	case .Down:
		source.y += st.height * f32(currentFrame)
	}

	// rl.DrawRectanglePro(
	// 	{position.x, position.y, st.width * scale, st.height * scale},
	// 	{0, st.height / 2},
	// 	rotation,
	// 	rl.RED,
	// )

	if flip do source.width = -source.width

	rl.DrawTexturePro(
		texture^,
		source,
		{position.x, position.y, worldDimensions.x * scale, st.height * scale},
		origin,
		rotation,
		tint,
	)
}
