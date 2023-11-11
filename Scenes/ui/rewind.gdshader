shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
const vec4 noise = vec4 (0.73724, 0.65463, 0.37368, 0.71777);
const float speed = 2.0;

float hash(vec2 p) {
  return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

void fragment() {
	float linepos = noise[int(hash(vec2(TIME,TIME))*6.0)%6];
	float line = pow(abs(mod(SCREEN_UV.y-TIME*speed+linepos,1.0)-0.5),10.0);
	COLOR.xyz = texture(screen_texture,SCREEN_UV).xyz + line *hash(SCREEN_UV+TIME)*1000.0;
}
