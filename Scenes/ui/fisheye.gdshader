shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
const vec2 size = vec2(0.3,0.3);
const float power = 7.0;
const float power_center = 0.2;
void fragment() {
	vec2 dist = SCREEN_UV-0.5;
	vec2 intersection = sign(dist)*min(abs(dist), size);
	
	//float border = sign(2.0 + sign((abs(dist)-size).x)+sign((abs(dist)-size).y));
	//float border = float(length(dist)>0.3);
	float general_distort =  power_center * pow(length(dist),4.0);
	float border_distort = power * pow((length(dist)-length(intersection)),3.0);
	vec2 lookup_uv = 0.5 + dist*(2.0*size + general_distort + border_distort);
	
	
	COLOR.xyz = texture(screen_texture, lookup_uv).xyz;
}
