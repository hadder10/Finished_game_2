shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
const float amount = 2.0;
const float speed = 1.5;

float get_line(vec2 uv){
	return pow(mod((uv.y-TIME*speed),(1.0/amount))*amount+0.2,0.1);
}

void fragment() {
	COLOR.xyz = texture(screen_texture, SCREEN_UV).xyz * get_line(SCREEN_UV);
}
