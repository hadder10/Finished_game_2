shader_type canvas_item;

uniform float magnitude_x : hint_range(-0.0100, 0.0100) = 0.0001;
uniform float magnitude_y : hint_range(-0.0100, 0.0100) = 0.0001;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv_offset = vec2(magnitude_x, magnitude_y);
	
	vec4 origin_color = texture(screen_texture, UV);
	
	float red = texture(screen_texture, UV + uv_offset).r;
	float green = origin_color.g * 0.6 + texture(screen_texture, UV + uv_offset).g * 0.2 + texture(screen_texture, UV - uv_offset).g * 0.2;
	float blue = texture(screen_texture, UV - uv_offset).b;
	float alpha = origin_color.a;
	
	COLOR = vec4(red, green, blue, alpha);
}
