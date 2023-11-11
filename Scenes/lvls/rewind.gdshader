shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
const mat4 noise = mat4(vec4 (0.73724, 0.65463, 0.37368, 0.71777), vec4(0.21322, 0.08427, 0.41298, 0.96896), vec4(0.70221, 0.71716, 0.23717, 0.54295),vec4(0.33804, 0.96680, 0.11032, 0.50197));
float hash(vec2 p) {
  return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}
void fragment() {
	float linepos = 0.1;
	float line = pow(abs(mod(SCREEN_UV.y-TIME*0.5,1.0)-0.5),10.0);
	COLOR.xyz = texture(screen_texture,SCREEN_UV).xyz + line *hash(SCREEN_UV+TIME)*1000.0;
}
