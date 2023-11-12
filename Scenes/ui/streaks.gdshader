shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
const float amount = 2.0;
const float speed = 1.5;
const vec4 noise = vec4 (0.23724, 0.65463, 0.37368, 0.71777);



float hash(vec2 p) {
	return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

float get_line(vec2 uv){
	float linepos = noise[int(hash(vec2(TIME,TIME))*6.0)%6]*1000.0;
	return pow(mod((uv.y-TIME*speed+linepos),(1.0/amount))*amount+0.2,0.1);
}


void fragment() {
	
	COLOR.xyz = texture(screen_texture, SCREEN_UV).xyz * get_line(SCREEN_UV);
}
