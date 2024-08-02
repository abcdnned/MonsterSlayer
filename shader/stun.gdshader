shader_type canvas_item;

uniform float hit_effect : hint_range(0, 1) = 0.0;

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec4 original_color = texture(TEXTURE, UV);
	vec4 hurt_color = vec4(1.0, 0.0, 0.0, original_color.a);
	
	COLOR = mix(original_color, hurt_color, hit_effect);
}