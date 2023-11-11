shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const vec2 pixel_size = vec2(4.0,2.0);
const vec3 palette = vec3(16,16,16);

void fragment() {
	vec2 final_screen_res = (1.0/SCREEN_PIXEL_SIZE)/pixel_size;
	vec2 lookup_uv = floor(SCREEN_UV*final_screen_res)/final_screen_res;
	vec3 old_color = texture(screen_texture, lookup_uv).xyz;
	vec4 new_color = vec4((floor(old_color*palette) + vec3(float(old_color.r>0.5/palette.r), float(old_color.g>0.5/palette.g), float(old_color.b>0.5/palette.b)))/palette, 0.0);
    vec2 place = mod(SCREEN_UV/SCREEN_PIXEL_SIZE, pixel_size) / pixel_size;
	vec4 newest_color = vec4(0.0,0.0,0.0,0.0);
	newest_color[int(floor(place.x * 3.5))] = new_color[int(floor(place.x*3.5))];
	
	COLOR.xyz = new_color.xyz/1.4 + newest_color.xyz/5.0;
	
}
