shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    if (color.a == 0.0) {
        // If the original color is fully transparent, set it to black with 60% opacity
        color.rgb = vec3(0.0, 0.0, 0.0);
        color.a = 1.0;
    }

    COLOR = color;
}