shader_type canvas_item;

uniform float blur_amount = 0.01;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    // Calculate the UV coordinates of the current pixel
    vec2 uv = SCREEN_UV;

    // Apply horizontal blur
    vec4 color = vec4(0.0);
    color += texture(screen_texture, uv + vec2(-2.0 * blur_amount, 0.0));
    color += texture(screen_texture, uv + vec2(-1.0 * blur_amount, 0.0));
    color += texture(screen_texture, uv);
    color += texture(screen_texture, uv + vec2(1.0 * blur_amount, 0.0));
    color += texture(screen_texture, uv + vec2(2.0 * blur_amount, 0.0));
    color /= 5.0;

    // Apply vertical blur
    vec4 final_color = vec4(0.0);
    final_color += texture(screen_texture, uv + vec2(0.0, -2.0 * blur_amount));
    final_color += texture(screen_texture, uv + vec2(0.0, -1.0 * blur_amount));
    final_color += color;
    final_color += texture(screen_texture, uv + vec2(0.0, 1.0 * blur_amount));
    final_color += texture(screen_texture, uv + vec2(0.0, 2.0 * blur_amount));
    final_color /= 5.0;

    // Output the final color
    COLOR = final_color;
}
