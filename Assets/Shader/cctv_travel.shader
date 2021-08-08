shader_type canvas_item;

uniform vec4 color_1 = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_2 = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 colors[2] = {color_1, color_2};
	
	vec4 temp = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	
	float min_diff = 1000.0;
	vec4 min_color = vec4(0.0, 0.0, 0.0, 1.0);
	for (int i = 0; i < colors.length(); i++) {
		float curr_dist = distance(colors[i], temp);
		if (curr_dist < min_diff) {
			min_diff = curr_dist;
			min_color = colors[i];
		}
	}
	COLOR.rgb = min_color.rgb;
}