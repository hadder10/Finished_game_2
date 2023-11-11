shader_type canvas_item;
uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 pixel = texture(screen, SCREEN_UV);
	COLOR = vec4(1.0 - pixel.rgb, pixel.a);
}
