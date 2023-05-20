shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR.rgb = vec3(COLOR.r + COLOR.g + COLOR.b) / 3.0;
}
