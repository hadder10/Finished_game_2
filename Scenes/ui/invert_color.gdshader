shader_type canvas_item;
uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 pixel = texture(screen, SCREEN_UV);
	
	float red = pixel.rgb[0];
	float green = pixel.rgb[1];
	float blue = pixel.rgb[2];

	red = 0.4 - (red - 0.4)*0.4;
	green = 0.5 - (green - 0.5)*0.4;
	blue = 0.5 - (blue - 0.5)*0.6;
	
	
	COLOR = vec4(red, green, blue, pixel.a);
	// COLOR = vec4(1.0 - pixel.rgb, pixel.a);
}
