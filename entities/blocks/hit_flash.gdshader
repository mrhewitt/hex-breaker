shader_type canvas_item;

// final color to use as flash highlight
uniform vec4 flash_color: source_color;
// lerp between default pixel and this value, 0 => original color, 1 => full flash effect
uniform float flash_value: hint_range(0.0,1.0,0.1);

void fragment() {
	// default color of sprite pixel
	vec4 texture_color = texture(TEXTURE,UV);
	// brighten pixel to set flash color
	COLOR = mix(texture_color, flash_color, flash_value);
	// but maintain its default transparency
	COLOR.a = texture_color.a;
}