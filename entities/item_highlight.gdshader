shader_type canvas_item;
render_mode unshaded;

uniform vec3 color1;
uniform vec3 color2;
uniform float speed = 1;

void fragment() {
	COLOR = vec4(mix(color1, color2, sin(TIME * speed) * .5 + .5), COLOR.a);
}
