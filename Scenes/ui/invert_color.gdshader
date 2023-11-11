shader_type canvas_item;
uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 pixel = texture(screen, SCREEN_UV);
	
//	float red = pixel.rgb[0];
//	float green = pixel.rgb[1];
	
	COLOR = vec4(1.0 - pixel.rgb, pixel.a);
}
