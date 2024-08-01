shader_type canvas_item;

uniform bool blink = false;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (blink) {
        tex_color.rgb = vec3(1.0); // Change to white
    }
    COLOR = tex_color;
}